app := ft-next-deployment-test

run:
	node server.js

deploy:
	# Clean+install dependencies
	git clean -fxd
	npm install
	$(MAKE) deploy-without-clean-and-install

deploy-without-clean-and-install:

	# Build steps
	echo 'Built' > public/built.html

	# Pre-deploy clean
	npm prune --production

	# Package+deploy
	@./node_modules/.bin/haikro build deploy \
		--app $(app) \
		--token $(HEROKU_AUTH_TOKEN) \
		--commit `git rev-parse HEAD`

test:
	./node_modules/.bin/jshint package.json server.js
