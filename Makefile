
.PHONY: install uninstall
install:
	@if [ -n ${REPO} ]; then \
		cd ./install && \
		git clone ${REPO} && \
		docker build -t virtual-campus-42nice ./ && \
		docker run -it --name=virtual-campus-42nice virtual-campus-42nice; \
	fi

uninstall:
	@cd ./install && \
	docker container rm virtual-campus-42nice && \
	docker image rm virtual-campus-42nice && \
	find  ./ ! -name "Dockerfile" -maxdepth 1 -exec rm -rf {} \;
