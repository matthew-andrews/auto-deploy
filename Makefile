app := ft-next-deployment-test

run:
	node server.js

install:
	# Clean+install dependencies
	git clean -fxd
	npm install

build:
	# Build steps
	echo 'Built' > public/built.html

	# Pre-deploy clean
	npm prune --production

	# Package
	@./node_modules/.bin/haikro build

deploy:
	# Deploy
	@./node_modules/.bin/haikro deploy \
		--app $(app) \
		--token $(HEROKU_AUTH_TOKEN) \
		--commit `git rev-parse HEAD` \
		--verbose

release:
	@curl -H "Authorization: token e162ebf3db95e7edd8ea4ff040db9ec2fe74e328" \
		-H "Accept: application/vnd.github.manifold-preview" \
		-H "Content-Type: application/gzip" \
		--data-binary @tmp/slug.tgz \
		"https://uploads.github.com/repos/matthew-andrews/auto-deploy/releases/v1.0.0/assets?name=1.0.0.zip"

test:
	./node_modules/.bin/jshint package.json server.js
