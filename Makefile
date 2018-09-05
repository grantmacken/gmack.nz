include .env
GIT_USER="$(shell git config --get user.name )"
GIT_REMOTE_ORIGIN_URl="$(shell git config --get remote.origin.url )"
GIT_REPO_FULL_NAME="$(shell echo $(GIT_REMOTE_ORIGIN_URl) | sed -e 's/git@github.com://g' | sed -e 's/\.git//g' )"
GIT_REPO_NAME="$(shell echo $(GIT_REPO_FULL_NAME) |cut -d/ -f2 )"
GIT_REPO_OWNER_LOGIN="$(shell echo $(GIT_REPO_FULL_NAME) |cut -d/ -f1 )"

.PHONY: stow
stow:
	@echo $(DOMAIN)
	@mkdir -p ./{modules,resources,unit-tests}
	@touch ./modules/t.xq
	@cd ../ && mkdir -p dorex/domains/$(DOMAIN)
	@cd ../ && stow -v -t "dorex/domains/$(DOMAIN)" $(DOMAIN)

	@#stow --ignore='Makefile|\.*' -t "../dorex/domains/$(DOMAIN)" $(DOMAIN)
#/home/gmack/projects/grantmacken/dorex/
