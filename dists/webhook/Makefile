
.PHONY: help all clean start

help: ## Show this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n"} /^[a-zA-Z_-]+:.*?##/ { printf " \033[36mmake %-17s\033[0m #%s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

all: start ## Start the server

start: /tmp/swmh/etc/hooks.json
	mkdir -p /tmp/swmh/run
	webhook -hooks /tmp/swmh/etc/hooks.json -verbose

/tmp/swmh/etc/hooks.json: hooks.json
	mkdir -p /tmp/swmh/etc
	sed -e 's#__PWD__#$(PWD)#;' hooks.json > $@

clean: ## Clean temporary files
	rm -rf /tmp/swmh
