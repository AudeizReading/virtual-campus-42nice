.PHONY: install defense launch run destroy uninstall

install:
	@./configure.sh dev

defense:
	@./configure.sh defense

launch:
	@docker build -t ${NAME}:on-built ./ && \
		docker run -it --name=${NAME} --env="DISPLAY=host.docker.internal:0" --env="/.Xauthority" --net=host -v /tmp/.X11-unix:/tmp/.X11-unix -v ~/.Xauthority:/.Xauthority ${OPTSINSTALL} ${NAME}:on-built
	
run:
	@./configure.sh run

destroy:
	@docker container rm virtual-defense-42nice && \
		docker image rm virtual-defense-42nice:on-built && \
	rm -rf ./corrections Dockerfile install-opts.sh

uninstall:
	@docker container rm virtual-campus-42nice && \
		docker image rm virtual-campus-42nice:on-built && \
	rm -rf Dockerfile install-opts.sh
