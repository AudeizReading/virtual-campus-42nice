#/bin/bash

# $1 : software name
# $2 : filename where to send
# $3 : what to install
function install_optional_software 
{
	printf "Install \033[33m%10s\033[0m?\t%20s: " ${1} "[y/N]"
	read -n 1 answer
	#
	if [ "${answer}" = "y" ]
	then
		printf "\n"
		cat >> ${2} << EOF
${3}
EOF
	fi
}

function display_error {
	printf "\033[31m[ERROR] $1\033[0m\n";
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

if ! docker info >/dev/null 2>&1; then
	display_error "Docker does not seem to be running, run it first and retry"
    exit 1
fi

# Si ./configure.sh run (on relance le container duquel on a exit)
if [ "${1}" = "run" ]
then
	docker restart virtual-campus-42nice
	docker attach virtual-campus-42nice
	exit 0
fi 

# Si OS == Mac, update xhost pr X11
if [ `uname ` = "Darwin" ];then
	# Regarde si la commande ne va pas crash
	if ! [ -x "$(command -v xhost)" ];then
		display_error "Prerequesites X Server command default 'xhost'";
	else
		# Pour autoriser l'utilisation du GPU pour OpenGL -> checker si pas de
		# soucis pour les autres users
		printf "Your sudo password will be asked for X11 setup (it is not keeped)."
		sudo defaults write org.xquartz.X11 enable_iglx -bool true
		if [ $? -ne 0 ];then
			printf "You need sudo rights for enabling org.xquartz.x11."
			exit 1;
		fi
		xhost +localhost;
	fi
fi 

# Debut Dockerfile, on recup l'image ubuntu 20.04 que j'ai pre-built
DOCKERFILE=Dockerfile
OPTSFILE=install-opts.sh
OPTSINSTALL=""
CONTAINER_NAME=virtual-campus-42nice

echo > "${OPTSFILE}"
cat > ${DOCKERFILE} << EOF
FROM audeizreading/virtual-campus-42nice:latest

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

install_optional_software "Node.js" "${OPTSFILE}" "curl -fsSL https://deb.nodesource.com/setup_19.x | bash - \\
	&& curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | tee /usr/share/keyrings/yarnkey.gpg >/dev/null \\
	&& echo \"deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main\" | tee /etc/apt/sources.list.d/yarn.list \\
	&& apt-get update  && apt upgrade -y && apt-get install -y nodejs yarn;"

install_optional_software "OpenGL" "${OPTSFILE}" "add-apt-repository ppa:oibaf/graphics-drivers && apt-get update -y && apt-get dist-upgrade -y && apt-get install -y libxmu-dev libxi-dev libgl-dev glew-utils libglu1-mesa-dev freeglut3-dev mesa-common-dev mesa-utils libgl1-mesa-dri libgl1-mesa-glx libglu1-mesa libosmesa6-dev libosmesa6 mesa-va-drivers mesa-vulkan-drivers freeglut3 libglew-dev mesa-vdpau-drivers && echo \"export LIBGL_ALWAYS_INDIRECT=1\\nexport MESA_GL_VERSION_OVERRIDE=4.3\\n\" >> /etc/bash.bashrc"
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
	CONTAINER_NAME=virtual-defense-42nice
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
