app := ft-next-deployment-test

run:
	node server.js

build:
	echo 'Built' > public/built.html

install:
	npm install --production

clean:
	git clean -fxd

deploy:
	${MAKE} clean
	${MAKE} install
	npm install haikro
	${MAKE} build

	./node_modules/.bin/haikro build deploy \
		--app $(app) \
		--token $(HEROKU_AUTH_TOKEN) \
		--commit `git rev-parse HEAD` \
		--entry "server.js"

test:
	./node_modules/.bin/jshint package.json server.js
