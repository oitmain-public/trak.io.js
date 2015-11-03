PHANTOM = mocha-phantomjs
PHANTOM_OPTS = --setting web-security=false --setting local-to-remote-url-access=true

build: build_trakio build_automagic

build_trakio: ice_src
	r.js -o config/trak.io.js

build_automagic: ice_src
	r.js -o config/trak.io.automagic.js

watch:
	guard --latency 0

min: build
	uglifyjs -mc -o trak.io.min.js trak.io.js
	uglifyjs -mc -o trak.io.automagic.min.js trak.io.automagic.js
	sed -i '' -e's/prototype.minified\=\!1/prototype.minified=!0/g' trak.io.min.js

zip: min
	-mkdir gzipped
	gzip -9 trak.io.min.js -c > gzipped/trak.io.min.js
	gzip -9 trak.io.automagic.min.js -c > gzipped/trak.io.automagic.min.js

deploy: build_and_test zip just_deploy

just_deploy:
	bin/deploy

server:
	node server.js &

ice: ice_tests ice_src

ice_tests:
	iced --bare --output test --compile test.iced

ice_src:
	iced --bare --output src --compile src.iced

# Starts the testing server.
test-server:
	node server.js -p 8001 &

install:
	bundle install
	npm install
	npm install -g bower
	npm install -g iced-coffee-script
	npm install -g mocha-phantomjs phantomjs
	npm install -g requirejs
	npm install -g uglify-js
	bower install

# Runs all the tests on travis.
build_and_test: min test

test: test-server min
	sleep 1
	$(PHANTOM) $(PHANTOM_OPTS) http://localhost:8001/test/trak.io.html -R dot
	$(PHANTOM) $(PHANTOM_OPTS) http://localhost:8001/test/trak.io.min.html -R dot
	$(PHANTOM) $(PHANTOM_OPTS) http://localhost:8001/test/trak.io.automagic.html -R dot
	$(PHANTOM) $(PHANTOM_OPTS) http://localhost:8001/test/trak.io.automagic.min.html -R dot
	make kill-test

# Runs only the non-minified core tests.
test-core: test-server ice
	-$(PHANTOM) $(PHANTOM_OPTS) http://localhost:8001/test/trak.io.html -R dot
	-$(PHANTOM) $(PHANTOM_OPTS) http://localhost:8001/test/trak.io.automagic.html -R dot
	make kill-test

# Opens all the tests in your browser.
test-browser: test-server
	open http://localhost:8001/test/trak.io.html
	open http://localhost:8001/test/trak.io.min.html
	open http://localhost:8001/test/trak.io.automagic.html
	open http://localhost:8001/test/trak.io.automagic.min.html

kill-test:
	kill -9 `cat pid.8001.txt`
	rm pid.8001.txt

kill:
	kill -9 `cat pid.8000.txt`
	rm pid.8000.txt
