.PHONY = build clean deps

build: deps
	# Nothing to build

deps: node_modules

clean:
	@rm -rf node_modules

node_modules: package.json
	@npm install
