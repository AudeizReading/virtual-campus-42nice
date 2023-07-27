.PHONY: install defense destroy uninstall

install:
	./configure.sh dev

defense:
	./configure.sh defense

run:
	./configure.sh run

destroy:
	@docker container rm virtual-defense-42nice && \
	docker image rm virtual-defense-42nice && \
	rm -rf ./corrections ./.cidfile

uninstall:
	@docker container rm virtual-campus-42nice && \
	docker image rm virtual-campus-42nice && \
	rm -rf ./dev 
