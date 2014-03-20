PHANTOM = node_modules/.bin/mocha-phantomjs
PHANTOM_OPTS = --setting web-security=false --setting local-to-remote-url-access=true

build: ice
	r.js -o build.js

watch:
	guard

min: build
	uglifyjs -mc -o trak.io.min.js trak.io.js

zip: min
	-mkdir gzipped
	gzip -9 trak.io.min.js -c > gzipped/trak.io.min.js

deploy: test zip
	bin/deploy

server:
	node server.js &

ice:
	iced -b -o test -c test.iced
	iced -b -o src -c src.iced

# Starts the testing server.
test-server:
	node server.js -p 8001 &

install:
	component install
	npm install

# Runs all the tests on travis.
test: test-server min
	sleep 1
	$(PHANTOM) $(PHANTOM_OPTS) http://localhost:8001/test/trak.io.html -R dot
	$(PHANTOM) $(PHANTOM_OPTS) http://localhost:8001/test/trak.io.min.html -R dot
	make kill-test

# Runs only the non-minified core tests.
test-core: test-server ice
	-$(PHANTOM) $(PHANTOM_OPTS) http://localhost:8001/test/trak.io.html -R dot
	make kill-test

# Opens all the tests in your browser.
test-browser: test-server
	open http://localhost:8001/test/trak.io.html
	open http://localhost:8001/test/trak.io.min.html

kill-test:
	kill -9 `cat pid.8001.txt`
	rm pid.8001.txt

kill:
	kill -9 `cat pid.8000.txt`
	rm pid.8000.txt

# components: component.json
#	@component install --dev

# clean:
#	rm -fr build components template.js

# .PHONY: clean
