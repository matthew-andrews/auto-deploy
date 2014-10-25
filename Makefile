app := ft-next-deployment-test

run:
	node server.js

deploy:
	# Clean+install dependencies
	git clean -fxd
	npm install

	# Build steps
	echo 'Built' > public/built.html

	# Pre-deploy clean
	npm prune --production

	# Package+deploy
	@./node_modules/.bin/haikro build deploy \
		--app $(app) \
		--token $(HEROKU_AUTH_TOKEN) \
		--commit `git rev-parse HEAD` \
		--entry "server.js"

test:
	./node_modules/.bin/jshint package.json server.js
