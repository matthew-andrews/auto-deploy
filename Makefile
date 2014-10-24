app := ft-next-deployment-test
time := $(shell date +'%Y%m%d-%H%M%S')
slug_name := $(app)-$(time)-slug.tgz
tar := gtar

run:
	node server.js

build:
	echo 'Built' > public/built.html

clean:
	git clean -fxd

deploy:
	@echo 'Cleaning and installing'
	${MAKE} clean

	@echo 'Creating slug object at $(slug_name)'
	${MAKE} build
	mkdir tmp
	mkdir ~/tmp
	$(tar) -cz --transform 's,^\.,./app,S' -f ~/tmp/$(slug_name) ./ && mv ~/tmp/$(slug_name) tmp/$(slug_name)

	@echo 'Deploy tar to Heroku'
	curl -s -X POST \
		-H 'Content-Type: application/json' \
		-H 'Accept: application/vnd.heroku+json; version=3' \
		-H "Authorization: $(HEROKU_AUTH_TOKEN)" \
		-d "{\"process_types\":{\"web\":\"node-v0.10.32-linux-x64/bin/node server.js\"}, \"commit\": \"`git rev-parse HEAD`\"}" \
		https://api.heroku.com/apps/$(app)/slugs > tmp/slug.json

	@curl -X PUT \
		-H "Content-Type:" \
		--data-binary @tmp/$(slug_name) \
		`node -e "var slug = require(process.cwd()+'/tmp/slug.json'); process.stdout.write(slug.blob.url);"` > tmp/slug-upload-output

	@curl -X POST \
		-H "Accept: application/vnd.heroku+json; version=3" \
		-H "Authorization: $(HEROKU_AUTH_TOKEN)" \
		-H "Content-Type: application/json" \
		-d "{\"slug\":\"`node -e "var slug = require(process.cwd()+'/tmp/slug.json'); process.stdout.write(slug.id);"`\"}" \
		https://api.heroku.com/apps/$(app)/releases

test:
	./node_modules/.bin/jshint package.json server.js
