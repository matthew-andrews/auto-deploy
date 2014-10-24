app := ft-next-deployment-test
time := $(shell date +'%Y%m%d-%H%M%S')
tar_options := $(shell if tar --version | grep 'bsdtar' >/dev/null; then echo "-cz -s ',^\.,./app,g'"; else echo "-cz --transform 's,^\.,./app,S'"; fi)

run:
	node server.js

build:
	echo 'Built' > public/built.html
	mkdir -p tmp
	cat .slugignore | tar $(tar_options) -f tmp/slug.tgz --exclude-from=- .

install: _install_node _install_npm

_install_npm:
	npm install --production

_install_node:
	curl http://nodejs.org/dist/v0.10.32/node-v0.10.32-linux-x64.tar.gz | tar xz

clean:
	git clean -fxd

deploy:
	${MAKE} clean
	${MAKE} install -j 2
	${MAKE} build

	@curl -s -X POST \
		-H 'Content-Type: application/json' \
		-H 'Accept: application/vnd.heroku+json; version=3' \
		-H "Authorization: $(HEROKU_AUTH_TOKEN)" \
		-d "{\"process_types\":{\"web\":\"node-v0.10.32-linux-x64/bin/node server.js\"}, \"commit\": \"`git rev-parse HEAD`\"}" \
		https://api.heroku.com/apps/$(app)/slugs > tmp/slug.json

	@curl -X PUT \
		-H "Content-Type:" --data-binary @tmp/slug.tgz \
		`node -e "process.stdout.write(require(process.cwd()+'/tmp/slug.json').blob.url);"` > /dev/null

	@curl -X POST \
		-H "Accept: application/vnd.heroku+json; version=3" \
		-H "Authorization: $(HEROKU_AUTH_TOKEN)" \
		-H "Content-Type: application/json" \
		-d "{\"slug\":\"`node -e "process.stdout.write(require(process.cwd()+'/tmp/slug.json').id);"`\"}" \
		https://api.heroku.com/apps/$(app)/releases

test:
	./node_modules/.bin/jshint package.json server.js
