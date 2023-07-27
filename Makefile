
.PHONY: install uninstall
install:
	@if [ -n ${REPO} ]; then \
		cd ./install && \
		git clone ${REPO} && \
		xhost +localhost && \
		docker build -t virtual-campus-42nice ./ && \
		docker run -it --name=virtual-campus-42nice --env="DISPLAY=host.docker.internal:0" --env="/.Xauthority" --net=host -v /tmp/.X11-unix:/tmp/.X11-unix -v ~/.Xauthority:/.Xauthority virtual-campus-42nice; \
	fi
#		docker run -it --name=virtual-campus-42nice --env="DISPLAY=host.docker.internal:0" --net=host virtual-campus-42nice; \

uninstall:
	@cd ./install && \
	docker container rm virtual-campus-42nice && \
	docker image rm virtual-campus-42nice && \
	find  ./ ! -name "Dockerfile" -maxdepth 1 -exec rm -rf {} \;
