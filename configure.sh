#/bin/bash

# $1 : software name
# $2 : filename where to send
# $3 : what to install
function install_optional_software 
{
	printf "Install   \033[33m%10s\033[0m?\t%20s: " ${1} "[y/N]"
	read -n 1 answer
	printf "\n"
	#
	if [ "${answer}" = "y" ]
	then
		cat >> ${2} << EOF
${3}
EOF
	fi
}

# $1 : Message error
function display_error {
	printf "\033[31m[ERROR] $1\033[0m\n";
}

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

# Si ./configure.sh defense -> On lance un container pr defense = git clone
# du repo vogsphere depuis host + copie du projet dans le container +
# positionnement dans le repertoire de correction au demarrage du container
# Tout est erase lorsqu'on quitte le container
if [ "${1}" = "defense" ]
then
	read -p "Provide the repo's url: " repo
	if [ -n ${repo} ]; 
	then
		git clone ${repo} ./corrections
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

	# Configuration pour mettre le container en real-time 
	# Si pas de path, pas de real-time
	printf "Enter the path of the folder you need to access in real-time.\n"
	read -p "Your path: " path_work
	printf "\n"
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
		cat >> ${DOCKERFILE} << EOF
WORKDIR /tmp/dev/${FOLDER}
EOF
	else
		printf "\t\033[47;31mInvalid path\033[0m\n"
	fi
fi

cat >> ${DOCKERFILE} << EOF
ENTRYPOINT [ "/bin/bash" ]
EOF

# Regarde si docker est lancer
if ! [ -x "$(command -v docker container ls)" ];then
	display_error "Please run docker";
	exit 1;
fi

# Mise en place du container
make launch NAME="${CONTAINER_NAME}" OPTSINSTALL="${OPTSINSTALL}"
if [ "${1}" = "defense" ]
then
	make destroy
fi
