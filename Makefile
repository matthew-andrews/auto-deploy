app := ft-next-deployment-test
time := $(shell date +'%Y%m%d-%H%M%S')
slug_name := $(app)-$(time)-slug.tgz
tar := gtar

run:
	node server.js

build:
	echo 'Built' > public/built.html

install: _install_node _install_npm

_install_npm:
	npm install --production

_install_node:
	curl http://nodejs.org/dist/v0.10.32/node-v0.10.32-linux-x64.tar.gz | $(tar) xz

clean:
	git clean -fxd

deploy:
	@echo 'Cleaning and installing'
	${MAKE} clean
	${MAKE} install -j 2

	@echo 'Creating slug object at $(slug_name)'
	${MAKE} build
	mkdir tmp
	$(tar) -cz --transform 's,^\.,./app,S' -f /tmp/$(slug_name) ./ && mv /tmp/$(slug_name) tmp/$(slug_name)

	@echo 'Deploy tar to Heroku'
	curl -s -X POST \
		-H 'Content-Type: application/json' \
		-H 'Accept: application/vnd.heroku+json; version=3' \
		-d "{\"process_types\":{\"web\":\"node-v0.10.32-linux-x64/bin/node server.js\"}, \"commit\": \"`git rev-parse HEAD`\"}" \
		-n https://api.heroku.com/apps/$(app)/slugs > tmp/slug.json

	curl -X PUT \
		-H "Content-Type:" \
		--data-binary @tmp/$(slug_name) \
		`node -e "var slug = require(process.cwd()+'/tmp/slug.json'); process.stdout.write(slug.blob.url);"` > tmp/slug-upload-output

	curl -X POST \
		-H "Accept: application/vnd.heroku+json; version=3" \
		-H "Content-Type: application/json" \
		-d "{\"slug\":\"`node -e "var slug = require(process.cwd()+'/tmp/slug.json'); process.stdout.write(slug.id);"`\"}" \
		-n https://api.heroku.com/apps/$(app)/releases

test:
	./node_modules/.bin/jshint package.json server.js
