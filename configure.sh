#/bin/sh

if [ "${1}" = "run" ]
then
	docker restart virtual-campus-42nice
	docker attach virtual-campus-42nice
	exit 0
fi 

if [ `uname ` = "Darwin" ]; then \
	xhost +localhost; \
fi 

DOCKERFILE=Dockerfile
cat > ${DOCKERFILE} << EOF
FROM audeizreading/virtual-campus-42nice:latest

EOF

read -n 1 -p "Do you need Firefox ? [y/n]: " answer
printf "\n"

if [ "${answer}" = "y" ]
then
cat >> ${DOCKERFILE} << EOF
RUN apt -y upgrade \\ 
	&& apt update -y \\
	&& apt install -y firefox 

EOF
fi

#read -n 1 -p "Do you need Node.js ? [y/n]: " answer
#printf "\n"
#
#if [ "${answer}" = "y" ]
#then
#cat >> ${DOCKERFILE} << EOF
#FROM node:latest
#  
#EOF
#fi

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
then
	read -n 1 -p "Do you need 42 header ? [y/n] : " need_header
	printf "\n"
	if [ "${need_header}" = "y" ]
	then
		read -p "Enter your 42 login: " login42
		printf "\n"
		cat >> ${DOCKERFILE} << EOF
ENV USER=${login42}
ENV MAIL=${login42}@student-42nice.fr

WORKDIR /etc/vim/plugin

RUN git clone https://github.com/42Paris/42header.git header \\
	&& cp header/plugin/stdheader.vim ./stdheader.vim \\
	&& rm -rf header \\
	&& apt remove -y git \\
	&& apt autoremove -y
EOF
	fi

	read -p "Enter the absolute path of the folder you need to access in real-time. Leave blank if you do not need the feature: " path_work
	printf "\n"
	eval path_work="${path_work}" # Sinon ca n'expand pas les ~ et $HOME
	if [ -n "${path_work}" ] && [ -d "${path_work}" ] || [ -f "${path_work}" ]
	then
		# recup dernier troncon du path
		FOLDER=`echo ${path_work} | rev | cut -f 1 -d / | rev`
		DEVPATH_="-v ${path_work}:/tmp/dev/${FOLDER}"
		cat >> ${DOCKERFILE} << EOF
WORKDIR /tmp/dev/${FOLDER}
EOF
	fi
fi

cat >> ${DOCKERFILE} << EOF
ENTRYPOINT [ "/bin/bash" ]
EOF

if [ "${1}" = "defense" ]
then
	make launch NAME=virtual-defense-42nice
	make destroy
elif [ "${1}" = "dev" ]
then
	make launch NAME=virtual-campus-42nice DEVPATH="${DEVPATH_}"
fi
