#!/usr/bin/env bash

# colors constants
RESET="\033[0m"
BOLD="\033[1m"
ITALIC="\033[3m"
UNDERLINE="\033[4m"
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
MAGENTA="\033[35m"
CYAN="\033[36m"
WHITE="\033[37m"
BG_RED="\033[41m"
BG_GREEN="\033[42m"
BG_YELLOW="\033[43m"
BG_BLUE="\033[44m"
BG_MAGENTA="\033[45m"
BG_CYAN="\033[46m"
BG_WHITE="\033[47m"

# $1 : software name
# $2 : filename where to send
# $3 : what to install
function install_optional_software 
{
	printf "Install ${YELLOW}%10s${RESET}?\t%20s: " ${1} "[y/N]"
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
	printf "${RED}[ERROR] $1${RESET}\n";
}

# $1 : msg
function warn {
	printf "${MAGENTA}%10s${RESET}${UNDERLINE}%-s${RESET}\n" "[WARN]: " "$1"
}

# Recherche l'OS
function getHost {
	host=`uname`
	case "${host}" in
		Darwin*)				echo "Mac OS X";;
		Linux*)					echo "Linux";;
		Linux*Microsoft)		echo "WSL";;
		CYGWIN*)				echo "Cygwin";;
		MINGW*)					echo "Mingw";;
		MSYS*|Msys)				echo "Git bash";;
		*)						echo "Not handled";;
	esac
}

function isMacHost {
	if [ "`getHost`" = "Mac OS X" ]
	then
		echo "yes"
		return 1;
	fi
	echo "no"
	return 0;
}

function isWindowsHost {
	if [ "`getHost`" = "WSL" ] || [ "`getHost`" = "Cygwin" ] || [ "`getHost`" = "Mingw" ] || [ "`getHost`" = "Git bash" ]
	then
		echo "yes"
		return 1;
	fi
	echo "no"
	return 0;
}

function isLinuxHost {
	if [ "`getHost`" = "Linux" ]
	then
		echo "yes"
		return 1;
	fi
	echo "no"
	return 0;
}

# check si on est sur Mac, si chip Intel ou Mxx (souci avec OpenGL)
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

function expandString {
	# expand tilde(~) and env variables ($HOME, $USER...)
	eval expandString="${1}"
	echo "${expandString}"
}

function resolvePath {
	path="${1}"
	path=`expandString "${path}"`
	if [ -e "${path}" ] # Is it a directory or a file?
	then
		if [ "${path:0:3}" = "../" ] || [ "${path:0:2}" = "./" ]
		then
			#transformation en path absolute
			expandPath=`readlink -f "${path}"`
			echo "${expandPath}"
			return 0
		elif [ "${path:0:1}" = "/" ]
		then
			echo "${path}"
			return 0
		else
			echo "`pwd`${path}"
			return 0
		fi
	else
		echo "${path}"
		return 1
	fi
}

# function createFolder {}

FOLDER=""
path_work=""
# TODO Laisser la possibilité de créer le répertoire
function normalize_path {
	printf "Enter the path of the folder you need to access in real-time.\n"
	read -e -p "Your path: " path_work
	printf "\n"
	path_display="${path_work}"
	path_work=`resolvePath "${path_work}"`
	if [ $? = 0 ]
	then
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

function askWorkFolder {
	ret=1
	while [ "${ret}" -ne 0 ];
	do
		normalize_path
		ret=$?
	done
	cat >> ${DOCKERFILE} << EOF
WORKDIR /tmp/dev/${FOLDER}
EOF
}

function importRCFile {
	# $1: bash ou vim
	printf "Import ${YELLOW}%17s${RESET}?\t%12s: \n${ITALIC}(%s)${RESET}: " "your ${1} rc file" "[y/N]" "Please consider not using plugins into your rc file, it should not work as it is too much specific to setup."
	read -n 1 need_rc
	printf "\n"
	if [ "${need_rc}" = "y" ]
	then
		case "${1}" in
			bash) 
				rc=".bashrc"
				containerPath="/etc/bash${rc}"
				;;
			vim) 
				rc=".vimrc"
				containerPath="/etc/vim/${rc:1}.local"
				;;
		esac
		userRC="~/${rc}"
		expandUserRC=`expandString "${userRC}"`
		resolvedUserRC=`resolvePath "${expandUserRC}"`
		if [ -e ${resolvedUserRC} ]
		then
			fileRC=`cat "${resolvedUserRC}"`
			echo "${fileRC}"
			cat >> ${OPTSFILE} << EOF
echo "${fileRC}" >> ${containerPath}
EOF
		else
			display_error "File ${userRC} not found"
		fi
	fi
}

function checkDockerRunning {
	# Check etat Docker
	if ! docker info >/dev/null 2>&1; then
		display_error "Docker does not seem to be running, run it first and retry"
    	exit 1
	fi
}

function dockerInspect {
	docker inspect -f '{{.State.Status}}' "${1}" 2> /dev/null
}

function setContainerName {
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
		if [[ `dockerInspect "${CONTAINER_NAME}"` = "exited" ]]
		then
			docker restart "${CONTAINER_NAME}"
			docker attach "${CONTAINER_NAME}"
			exit 0
		fi
	fi
}

function checkContainerState {
	# Si le container est en train de tourner c'est peut etre une erreur
	if ( [[ `dockerInspect "${1}"` = "exited" ]] || [[ `dockerInspect "${1}"` = "running" ]] ) && ! [[ "${2}" = "run" ]]
	then
		if [ "${2}" = "dev" ];
		then
			display_error "${1} is still running. Do you want to keep it? [Y/n]:"
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
			display_error "${1} is still running.\nIt will be removed, and you will have to restart the container.\n"
			make destroy
		fi
		# Obligé de sortir, impossible de relancer l'install du container dans la foulee
		exit 0
	fi
}

function allowConnectionXServer {
	is_localhost_bound_xhost=`xhost | grep "${1}" | awk -v host="${1}" 'BEGIN{i = 0;}{if($0 ~ host) i++;}END{print i}'`
		if [ "${is_localhost_bound_xhost}" = "0" ]
		then
			# On ajoute l'host a liste des clients du server X11 autorisés
			# ssi ce n'est pas deja fait
			xhost +"${1}";
		fi
}

function enableIglxForMac {
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
}

function setUpXServer {
	# Si OS == Mac, update xhost pr X11
	if [ `isMacHost` = "yes" ];then
		# Regarde si la commande ne va pas crash
		if ! [ -x "$(command -v xhost)" ];then
			display_error "Prerequesites X Server command default 'xhost'";
		else
				XHOSTDISPLAY="host.docker.internal"
				enableIglxForMac
				allowConnectionXServer "localhost"
		fi
	elif [ "`isWindowsHost`" = "yes" ];then
		if ! [ -x "$(command -v xhost)" ];then
			display_error "Prerequesites X Server command default 'xhost'\nPlease install it and retry. Check https://sourceforge.net/projects/vcxsrv/ for more information";
		else
			XHOSTDISPLAY=""
			allowConnectionXServer "localhost"
		fi
	elif [ "`isLinuxHost`" = "yes" ];then
			display_error "Why the Hell do you need this tool? You have already what we need !!!! (contact me if you really need to bypass this)";
	fi 
}

function recoveringBaseImageDocker {
	# Debut Dockerfile, on recup l'image ubuntu 20.04 que j'ai pre-built
	cat > ${DOCKERFILE} << EOF
FROM audeizreading/virtual-campus-42nice:latest

EOF
}

function updateNorminette {
	# Maj norminette a l'instruction ON-BUILT de l'image de base
	# Ca ne change rien, la maj se fera a chq make install ou make defense
	cat >> "${OPTSFILE}" << EOF
python3 -m pip install --upgrade norminette;

EOF
}

function suggestFirefox {
	install_optional_software "Firefox" "${OPTSFILE}" "apt -y update && apt upgrade -y && apt install -y firefox"
}

function suggestDocker {
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
}

function suggestNodeJS {
	install_optional_software "Node.js" "${OPTSFILE}" "curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \\
	&& curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | tee /usr/share/keyrings/yarnkey.gpg >/dev/null \\
	&& echo \"deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main\" | tee /etc/apt/sources.list.d/yarn.list \\
	&& apt-get update  && apt upgrade -y && apt-get install -y nodejs yarn;"
}
function suggestOpenGL {
	# ppa:kisak/kisak-mesa ou ppa:oibaf/graphics-drivers si on a besoin de mesa 
	install_optional_software "OpenGL" "${OPTSFILE}" "apt update && apt -y install software-properties-common dirmngr apt-transport-https lsb-release ca-certificates && add-apt-repository -usy ppa:oibaf/graphics-drivers && apt-get install -y libxmu-dev libxi-dev libgl-dev glew-utils libglu1-mesa-dev freeglut3-dev mesa-common-dev mesa-utils libgl1-mesa-dri libgl1-mesa-glx libglu1-mesa libosmesa6-dev libosmesa6 mesa-va-drivers mesa-vulkan-drivers freeglut3 libglew-dev mesa-vdpau-drivers && echo \"export LIBGL_ALWAYS_INDIRECT=1\\nexport MESA_GL_VERSION_OVERRIDE=4.3\\n\" >> /etc/bash.bashrc"
}

function suggest42Header {
	# Configuration en tete 42
	printf "Configure ${YELLOW}%10s${RESET}?\t%20s: " "42 header" "[y/N]"
	read -n 1 need_header
	printf "\n"
	if [ "${need_header}" = "y" ]
	then
		printf "Enter your ${YELLOW}%10s${RESET}\t%20s: " "42 login" "(8 max)"
		# TODO: pouvoir effacer sa saisie si on se trompe
		read -en 9 login42
		login42="${login42:0:8}"
		res=1
		if [ -z ${login42} ] || [ ${login42} = "\n" ]
		then
			login42="${USER}"
		else # on verife que la saisie est ok sinon on refait saisir
			while [ ${res} -ne 0 ];
			do
				printf "You have entered: ${CYAN}%s${RESET}.\nConfirm?\t%30s: " "${login42}" "[Y/n]"
				read -n 1 answer
				if [ "${answer}" = "n" ]
				then
					printf "Enter your ${YELLOW}%10s${RESET}\t%20s: " "42 login" "(8 max)"
					read -en 9 login42
					login42="${login42:0:8}"
					res=1
				else
					res=0
				fi
			done
		fi
		printf "\n"
		cat >> ${OPTSFILE} << EOF
echo "export USER=${login42}\nexport MAIL=${login42}@student.42nice.fr\n" >> /etc/bash.bashrc

EOF
	fi
}

function setUpEntrypoint {
	cat >> ${DOCKERFILE} << EOF
ENTRYPOINT [ "/bin/bash" ]
EOF
}

function setUpDefenseContainer {
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
}
function setUpDevContainer {
	suggest42Header
	askWorkFolder
}

function generateConfigFiles {
	# Debut Dockerfile, on recup l'image ubuntu 20.04 que j'ai pre-built
	DOCKERFILE=Dockerfile
	OPTSFILE=install-opts.sh
	OPTSINSTALL=""

	echo > "${OPTSFILE}"
	recoveringBaseImageDocker
	updateNorminette
	suggestFirefox
	suggestDocker
	suggestNodeJS
	suggestOpenGL
	importRCFile "bash"
	importRCFile "vim"
	if [ "${1}" = "defense" ]
	then
		setUpDefenseContainer
	elif [ "${1}" = "dev" ]
	then
		setUpDevContainer
	fi
	setUpEntrypoint
}

function startContainer {
	# Mise en place du container
	make launch NAME="${CONTAINER_NAME}" OPTSINSTALL="${OPTSINSTALL}" DISPLAY="${XHOSTDISPLAY}"
	if [ "${1}" = "defense" ]
	then
		if [[ `dockerInspect "${CONTAINER_NAME}"` = "exited" ]]
		then
			make destroy
		fi
	fi
}


checkDockerRunning
setContainerName "${1}"
checkContainerState "${CONTAINER_NAME}" "${1}"

setUpXServer
generateConfigFiles "${1}"
startContainer "${1}"
