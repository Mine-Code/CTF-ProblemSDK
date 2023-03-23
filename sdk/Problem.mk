.PHONY: all
all: out.tar.gz

.mc_ctf/test: out.tar.gz
	@if [ -e $(PWD)/.mc_ctf/test -a -d $(PWD)/.mc_ctf/test ]; then \
		printf "\e[1;32mUpdating .mc_ctf/test directory...\e[0m\n"; \
		tar -xf out.tar.gz -C .mc_ctf/test; \
		printf "\e[33mUpdated .mc_ctf/test directory\e[0m\n"; \
	else\
	  printf "\e[1;32mSetupping .mc_ctf/test directory...\e[0m\n"; \
		mkdir -p .mc_ctf/test; \
		tar -xf out.tar.gz -C .mc_ctf/test; \
		printf "\e[33mSetupped .mc_ctf/test directory\e[0m\n"; \
	fi

.PHONY: test
test: out.tar.gz .mc_ctf/test
	@printf "\e[32mStarting container\e[0m\n"
	$(eval CID := $(shell docker run -d -it -v $(PWD)/.mc_ctf/test:/mnt minecode-ctf-runner:latest /bin/bash))
	@printf "\e[33mCreated container\e[0m \e[32m$(CID)\e[0m\n"

	@printf "\e[32mStarting test\e[0m\n"
	@docker exec $(CID) runtime.sh /mnt/.mc_ctf/init.sh
	@docker exec -d $(CID) runtime.sh /mnt/.mc_ctf/daemon.sh
	@docker exec $(CID) runtime.sh /mnt/.mc_ctf/runtime.sh
	@docker stop -s 9 $(CID)

.PHONY: clean
clean:
	rm out.tar.gz src/metadata.json .mc_ctf/test

out.tar.gz: $(wildcard src/*) src/metadata.json \
		.mc_ctf/.env .mc_ctf/runtime.sh \
		.mc_ctf/init.sh .mc_ctf/daemon.sh
	@printf "\e[1;32mCreating archive\e[0m \e[1;33m$@\e[0m\n"
	@cd src; tar -cf out.tar *; cd ..
	@mv src/out.tar .

	@printf "\e[33m  - Appending .mc_ctf/*.sh to archive\e[0m \e[1;33m$@\e[0m\n"
	@tar -rf out.tar .mc_ctf/*.sh

	@printf "\e[33m  - Appending .mc_ctf/.env to archive\e[0m \e[1;33m$@\e[0m\n"
	@cd .mc_ctf; tar -rf ../out.tar .env; cd ..

	@printf "\e[32mCompressing out.tar\e[0m\n"
	@gzip out.tar
	@printf "\e[32mCreated archive\e[0m \e[1;33m$@\e[0m\n"


src/metadata.json: .mc_ctf/config.json .mc_ctf/flag.txt
	@printf "\e[32mCreating\e[0m \e[1;33m$@\e[0m\n"
	@{ \
		cat .mc_ctf/config.json; \
		printf '{'; \
			printf '"type": "challenge",'; \
			printf '"version": 0,'; \
			printf '"flag_hash": "'; \
			cat .mc_ctf/flag.txt | sha256sum | rev | cut -c 4- | rev | tr -d '\n'; \
			printf '",'; \
			printf '"tasks": {'; \
				printf '"runtime": "/mnt/.mc_ctf/runtime.sh", '; \
				printf '"init": "/mnt/.mc_ctf/init.sh", '; \
				printf '"daemon": "/mnt/.mc_ctf/daemon.sh"'; \
			printf '}'; \
		printf '}'; \
	} | jq -s ".[0] * .[1]" > $@