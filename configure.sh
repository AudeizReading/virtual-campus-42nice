#/bin/bash

# $1 : software name
# $2 : filename where to send
# $3 : what to install
function install_optional_software 
{
	printf "Install \033[33m%10s\033[0m?\t%20s: " ${1} "[y/N]"
	read -n 1 answer
	
	if [ "${answer}" = "y" ]
	then
		cat >> ${2} << EOF
${3}
EOF
	fi
	if [ -n "${answer}" ]
	then
		printf "\n"
	fi
}

# $1 : msg d'erreur
function display_error {
	printf "\033[31m[ERROR] $1\033[0m\n";
}

# $1 : msg
function warn {
	printf "\033[35m%10s\033[0m\033[4m%-s\033[0m\n" "[WARN]: " "$1"
}

# check si on est sur Mac, si chip Intel ou Mxx (souci avec OpenGL)
function isMacHost {
	if [ `uname` = "Darwin" ]
	then
		echo "yes"
		return 1;
	fi
	echo "no"
	return 0;
}

function isMxxMac {
	if [ `isMacHost` = "yes" ]
	then
		cpu=`sysctl -n machdep.cpu.brand_string`
		if ! [[ "${cpu}" =~ "Intel" ]]
		then
			warn "Your CPU is ${cpu}"
			return 1;
		fi
	fi
	return 0;
}

FOLDER=""
path_work=""
# TODO Laisser la possibilité de créer le répertoire
function normalize_path {
	printf "Enter the path of the folder you need to access in real-time.\n"
	read -p "Your path: " path_work
	printf "\n"
	path_display="${path_work}"
	eval path_work="${path_work}" # Sinon ca n'expand pas les ~ et $HOME
	if [ -n "${path_work}" ] && [ -d "${path_work}" ]
	then
		## si path relatif, on convertit en path absolu
		if [ "${path_work:0:3}" = "../" ] || [ "${path_work:0:2}" = "./" ]
		then
			path_work=`readlink -f "${path_work}"`
		fi	
		# recup dernier troncon du path et preparation des differents paths dont
		# on va se servir pour faire du temps-reel
		FOLDER=`basename "${path_work}"`
		OPTSINSTALL="-v ${path_work}:/tmp/dev/${FOLDER} "${OPTSINSTALL}
		return 0
	else
		display_error "Invalid Path ${path_display}"
		printf "Do you want to keep your choice?\n(an invalid path will anyway be rejected) %20s: " "[y/q/N]"
		read -n 1 answer
		printf "\n"
		if [ "${answer}" = "y" ] && [ -z "${path_work}" ]
		then
			return 0
		elif [ "${answer}" = "q" ];
		then
			display_error "EXIT"
			exit 1;
		fi
		return 1
	fi	
}

# Check etat Docker
if ! docker info >/dev/null 2>&1; then
	display_error "Docker does not seem to be running, run it first and retry"
    exit 1
fi

if [ "${1}" = "dev" ]
then
	CONTAINER_NAME=virtual-campus-42nice
elif [ "${1}" = "defense" ]
then
	CONTAINER_NAME=virtual-defense-42nice
# Si ./configure.sh run (on relance le container duquel on a exit)
elif [ "${1}" = "run" ]
then
	CONTAINER_NAME=virtual-campus-42nice
	if [[ `docker inspect -f '{{.State.Status}}' "${CONTAINER_NAME}"` = "exited" ]]
	then
		docker restart "${CONTAINER_NAME}"
		docker attach "${CONTAINER_NAME}"
		exit 0
	fi
fi

# Si le container est en train de tourner c'est peut etre une erreur
if ( [[ `docker inspect -f '{{.State.Status}}' "${CONTAINER_NAME}" 2>/dev/null` = "running" ]] || [[ `docker inspect -f '{{.State.Status}}' "${CONTAINER_NAME}" 2> /dev/null` = "exited" ]] ) && ! [[ ${1} = "run" ]]
then
	if [ "${1}" = "dev" ];
	then
		display_error "${CONTAINER_NAME} is still running. Do you want to keep it? [Y/n]:"
		read -n1 answer
		if [ -n "${answer}" ]
		then
			printf "\n"
		fi
		if [ "${answer}" = "n" ]; then
			make uninstall
		else
			make run
		fi
	elif [ "${2}" = "defense" ];
	then
		display_error "${CONTAINER_NAME} is still running.\nIt will be removed, and you will have to restart the container.\n"
		make destroy
	fi
	# Obligé de sortir, impossible de relancer l'install du container dans la foulee
	exit 0
fi
# Fin check Docker


# Si OS == Mac, update xhost pr X11
if [ `uname` = "Darwin" ];then
	# Regarde si la commande ne va pas crash
	if ! [ -x "$(command -v xhost)" ];then
		display_error "Prerequesites X Server command default 'xhost'";
	else
		# On enable iglx (nécessaire pour run des apps GUI OpenGL) que si ce
		# n'est pas deja fait
		# https://services.dartmouth.edu/TDClient/1806/Portal/KB/ArticleDet?ID=89669
		iglx_state=`defaults read org.xquartz.X11 | grep enable_iglx | awk '$0 ~ /enable_iglx/ && $3 ~ /1/ {print "iglx enabled"}'`
		if ! [ "${iglx_state}" = "iglx enabled" ]
		then
			xquartz_version=`brew info --cask xquartz | grep xquartz: | awk '$0 ~ /xquartz/ && $3 >= 2.8 {print "sup 2.8"}'`
			if [ "${xquartz_version}" = "sup 2.8" ]
			then
				defaults write org.xquartz.X11 enable_iglx -bool true
			else
				defaults write org.macosforge.xquartz.X11 enable_iglx -bool true
			fi
			iglx_state=`defaults read org.xquartz.X11 | grep enable_iglx | awk '$0 ~ /enable_iglx/ && $3 ~ /1/ {print "iglx enabled"}'`
			if ! [ "${iglx_state}" = "iglx enabled" ]
			then
				warn "Fatal error encounters when setting up the X11 server.\nPlease type the following instructions into your terminal et restart the installation of the container:\n\t\033[4mdefaults write org.xquartz.X11 enable_iglx -bool true\033[0m\n"
				exit 1
			fi
		fi
		is_localhost_bound_xhost=`xhost | grep localhost | awk 'BEGIN{i = 0;}{if($0 ~ localhost) i++;}END{print i}'`
		if [ "${is_localhost_bound_xhost}" = "0" ]
		then
			# On ajoute localhost a liste des clients du server X11 autorisés
			# ssi ce n'est pas deja fait
			xhost +localhost;
		fi
	fi
fi 

# Debut Dockerfile, on recup l'image ubuntu 20.04 que j'ai pre-built
DOCKERFILE=Dockerfile
OPTSFILE=install-opts.sh
OPTSINSTALL=""

echo > "${OPTSFILE}"
cat > ${DOCKERFILE} << EOF
FROM audeizreading/virtual-campus-42nice:latest

EOF

cat >> "${OPTSFILE}" << EOF
python3 -m pip install --upgrade norminette;

EOF

install_optional_software "Firefox" "${OPTSFILE}" "apt -y update && apt upgrade -y && apt install -y firefox"

answer="n"
install_optional_software "Docker" "${OPTSFILE}" "apt-get install -y ca-certificates gnupg \\
	&& install -m 0755 -d /etc/apt/keyrings \\
	&& curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \\
	&& chmod a+r /etc/apt/keyrings/docker.gpg \\
	&& echo \"deb [arch=\"\$(dpkg --print-architecture)\" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \"\$(. /etc/os-release && echo \"\$VERSION_CODENAME\")\" stable\" | tee /etc/apt/sources.list.d/docker.list > /dev/null \\
	&& apt-get update -y && apt upgrade -y \\
	&& apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin\\
	&& groupadd -f docker \\
	&& usermod -aG docker root \\
	&& newgrp docker \\
	&& apt-get remove -y --auto-remove ca-certificates gnupg;"
if [ "${answer}" = "y" ]
then
	OPTSINSTALL="-v /var/run/docker.sock:/var/run/docker.sock "${OPTSINSTALL}
fi

install_optional_software "Node.js" "${OPTSFILE}" "curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \\
	&& curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | tee /usr/share/keyrings/yarnkey.gpg >/dev/null \\
	&& echo \"deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main\" | tee /etc/apt/sources.list.d/yarn.list \\
	&& apt-get update  && apt upgrade -y && apt-get install -y nodejs yarn;"

install_optional_software "OpenGL" "${OPTSFILE}" "apt -y install software-properties-common dirmngr apt-transport-https lsb-release ca-certificates && add-apt-repository -usy ppa:oibaf/graphics-drivers && apt-get install -y libxmu-dev libxi-dev libgl-dev glew-utils libglu1-mesa-dev freeglut3-dev mesa-common-dev mesa-utils libgl1-mesa-dri libgl1-mesa-glx libglu1-mesa libosmesa6-dev libosmesa6 mesa-va-drivers mesa-vulkan-drivers freeglut3 libglew-dev mesa-vdpau-drivers && echo \"export LIBGL_ALWAYS_INDIRECT=1\\nexport MESA_GL_VERSION_OVERRIDE=4.3\\n\" >> /etc/bash.bashrc"
# Si ./configure.sh defense -> On lance un container pr defense = git clone
# du repo vogsphere depuis host + copie du projet dans le container +
# positionnement dans le repertoire de correction au demarrage du container
# Tout est erase lorsqu'on quitte le container
if [ "${1}" = "defense" ]
then
	read -p "Provide the repo's url: " repo
	if [ -n ${repo} ]; 
	then
		rm -rf ./corrections
		git clone ${repo} ./corrections
		if [ $? -ne 0 ];
		then
			display_error "The clone encounters trouble..."
			rm -rf ./corrections
			exit 1
		fi
	fi
	cat >> ${DOCKERFILE} << EOF
WORKDIR /tmp/corrections
COPY ./corrections .

EOF
elif [ "${1}" = "dev" ]
	# Si ./configure.sh dev -> on cree un container pour un environnement de dev
then
	# Configuration en tete 42
	printf "Configure \033[33m%10s\033[0m?\t%20s: " "42 header" "[y/n]"
	read -n 1 need_header
	printf "\n"
	if [ "${need_header}" = "y" ]
	then
		printf "Enter your \033[33m%10s\033[0m\t%20s: " "42 login" "(8 max)"
		read -n 8 login42
		if [ -z ${login42} ] || [ ${login42} = "\n" ]
		then
			login42="${USER}"
		fi
		printf "\n"
		cat >> ${DOCKERFILE} << EOF
ENV USER=${login42}
ENV MAIL=${login42}@student.42nice.fr

EOF
	fi

	ret=1
	while [ "${ret}" -ne 0 ];
	do
		normalize_path
		ret=$?
	done
cat >> ${DOCKERFILE} << EOF
WORKDIR /tmp/dev/${FOLDER}
EOF
fi

cat >> ${DOCKERFILE} << EOF
ENTRYPOINT [ "/bin/bash" ]
EOF


# Mise en place du container
make launch NAME="${CONTAINER_NAME}" OPTSINSTALL="${OPTSINSTALL}"
if [ "${1}" = "defense" ]
then
	if [[ `docker inspect -f '{{.State.Status}}' "${CONTAINER_NAME}" 2>/dev/null` = "exited" ]]
	then
		make destroy
	fi
fi
