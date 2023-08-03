#/bin/bash

# Si ./configure.sh run (on relance le container duquel on a exit)
if [ "${1}" = "run" ]
then
	docker restart virtual-campus-42nice
	docker attach virtual-campus-42nice
	exit 0
fi 

# Si OS == Mac, update xhost pr X11
if [ `uname ` = "Darwin" ]; then \
	xhost +localhost; \
fi 

# Debut Dockerfile, on recup l'image ubuntu 20.04 que j'ai pre-built
DOCKERFILE=Dockerfile
cat > ${DOCKERFILE} << EOF
FROM audeizreading/virtual-campus-42nice:latest as builder

EOF

# Demande si intall Firefox
printf "Do you need \033[31mFirefox\033[0m ? [y/n]: "
read -n 1 answer
printf "\n"

if [ "${answer}" = "y" ]
then
cat >> ${DOCKERFILE} << EOF
RUN apt -y upgrade \\ 
	&& apt update -y \\
	&& apt install -y firefox 

EOF
fi

# Demande si besoin d'utiliser Docker dans le container (inception?)
printf "Do you need \033[31mDocker\033[0m ? [y/n]: "
read -n 1 answer
printf "\n"
#
if [ "${answer}" = "y" ]
then
	socket_docker="-v /var/run/docker.sock:/var/run/docker.sock "
cat >> ${DOCKERFILE} << EOF
RUN apt-get install -y ca-certificates gnupg \\
	&& install -m 0755 -d /etc/apt/keyrings \\
	&& curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \\
	&& chmod a+r /etc/apt/keyrings/docker.gpg \\
	&& echo "deb [arch="\$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu "\$(. /etc/os-release && echo "\$VERSION_CODENAME")" stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \\
	&& apt-get update -y\\
	&& apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin\\
	&& groupadd -f docker \\
	&& usermod -aG docker root \\
	&& newgrp docker \\
	&& apt-get remove -y --auto-remove ca-certificates gnupg
EOF
fi

# Demande si intall node
printf "Do you need \033[31mNode.js\033[0m ? [y/n]: "
read -n 1 answer
printf "\n"

if [ "${answer}" = "y" ]
then
cat >> ${DOCKERFILE} << EOF
RUN curl -fsSL https://deb.nodesource.com/setup_19.x | bash - \\
	&& curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | tee /usr/share/keyrings/yarnkey.gpg >/dev/null \\
	&& echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | tee /etc/apt/sources.list.d/yarn.list \\
	&& apt-get update && apt-get install -y nodejs yarn 
  
EOF
fi

# Demande si intall android
# Attention image android != si arm sdkmanager --list pour obtenir la liste des
# repositories
printf "Do you need \033[31mAndroid\033[0m ? [y/n]: "
read -n 1 answer
printf "\n"

if [ "${answer}" = "y" ]
then
	if [ `uname` = "Darwin" ]
	then
		kextstat | grep intel > /dev/null
		ret_val=$?
	fi
	echo "return value: ${ret_val}"
	if [ `uname` = "Darwin" ] && [ "${ret_val}" != "0" ]
	then
		printf "It is better that you install Android Studio by your own for the moment.\nAndroid Emulator needs KVM or a CPU that handles the virtualisation. As Docker uses HyperVisualisor at its top most-level, it can not reuse it.\n"
	else
#	then
cat >> ${DOCKERFILE} << EOF
RUN dpkg --add-architecture i386 \\
	&& apt-get update -y && apt-get install -y openjdk-11-jdk coreutils libglu1 libpulse-dev libasound2 libc6 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxi6 libxtst6 libnss3\\
	&& wget https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2022.2.1.19/android-studio-2022.2.1.19-linux.tar.gz -P /tmp && echo "6c0b4f949237470a905fac69122ed2f13d880dcff7f4c38d537885a5f8bcbf70 */tmp/android-studio-2022.2.1.19-linux.tar.gz" | shasum -a 256 -c && mkdir -p /opt/android-studio  && cd /opt/android-studio && tar -xzvf /tmp/android-studio-2022.2.1.19-linux.tar.gz \\ 
	&& apt-get install -y libz1 libncurses5 libbz2-1.0:i386 libstdc++6 libbz2-1.0 lib32stdc++6 lib32z1 && apt-get clean -y && apt-get purge -y
EOF
	fi
fi

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
elif [ "${1}" = "dev" ]
	# Si ./configure.sh dev -> on cree un container pour un environnement de dev
then
	# Installation en tete 42
	printf "Do you need \033[31m42 header\033[0m ? [y/n]: "
	read -n 1 need_header
	printf "\n"
	if [ "${need_header}" = "y" ]
	then
		printf "Enter your \033[31m42 login\033[0m: "
		read -n 8 login42
		if [ -z login42 ]
		then
			login42="${USER}"
		fi
		printf "\n"
		cat >> ${DOCKERFILE} << EOF
ENV USER=${login42}
ENV MAIL=${login42}@student.42nice.fr

WORKDIR /etc/vim/plugin

RUN git clone https://github.com/42Paris/42header.git header \\
	&& cp header/plugin/stdheader.vim ./stdheader.vim \\
	&& rm -rf header \\
	&& apt remove -y git \\
	&& apt autoremove -y
EOF
	fi

	# Configuration pour mettre le container en real-time 
	# Si pas de path, pas de real-time
	printf "Enter the path of the folder you need to access in real-time.\nLeave blank if you do not need the feature.\nBe aware that you won't be in real-time and won't be able to sync your files from the container to the host and vice-versa, if you do not give it.\n"
	read -p "Your path: " path_work
	printf "\n"
	eval path_work="${path_work}" # Sinon ca n'expand pas les ~ et $HOME
	if [ -n "${path_work}" ] && [ -d "${path_work}" ] || [ -f "${path_work}" ]
	then
		## si path relatif, on convertit en path absolu
		if [ "${path_work:0:3}" = "../" ] || [ "${path_work:0:2}" = "./" ]
		then
			path_work=`readlink -f "${path_work}"`
		fi	
		# recup dernier troncon du path et preparation des differents paths dont
		# on va se servir pour faire du temps-reel
		FOLDER=`basename "${path_work}"`
		DEVPATH_="-v ${path_work}:/tmp/dev/${FOLDER}"
		cat >> ${DOCKERFILE} << EOF
WORKDIR /tmp/dev/${FOLDER}
EOF
	fi
fi

cat >> ${DOCKERFILE} << EOF
ENTRYPOINT [ "/bin/bash" ]
EOF

# Mise en place du container
if [ "${1}" = "defense" ]
then
	make launch NAME=virtual-defense-42nice DEVPATH="${gradle_opt} ${socket_docker}"
	make destroy
elif [ "${1}" = "dev" ]
then
	make launch NAME=virtual-campus-42nice DEVPATH="${gradle_opt} ${DEVPATH_} ${socket_docker}"
fi
