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
	read -p "Provide the relative path of the work that you need for dev (let empty if no need): " path_work
	if [ -n "${path_work}" ] && [ -d "${path_work}" ] || [ -f "${path_work}" ]
	then
		mkdir -p dev 
		cp -R ${path_work} ./dev/
		cat >> ${DOCKERFILE} << EOF
WORKDIR /tmp/dev
COPY ./dev/ .
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
else
	make launch NAME=virtual-campus-42nice
fi
