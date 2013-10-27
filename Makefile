DEFAULT:
	@echo 'Targets:'
	@echo ''
	@echo ' compile: compile coffee files to js'
	@echo ' clean: removed compiled js files'
	@echo ' test: run all tests locally'
	@echo ' test_e2e: run e2e tests locally'
	@echo ' test_midway: run midway tests locally'
	@echo ' test_e2e_sauce: run e2e tests on sauce'
	@echo ' test_midway_sauce_connect: run midway tests on sauce using sauce connect'
	@echo ''
	@echo 'Notes:'
	@echo '  - For sauce tests set the environment variables SAUCE_USERNAME and SAUCE_ACCESS_KEY.'
	@echo ''


compile:
	@./node_modules/.bin/coffee --compile index.coffee lib test

clean:
	@rm -f lib/*.js
	@find test -name '*.js' -exec rm {} \;
	@rm -f index.js

test:
	make test_midway
	make test_e2e

test_e2e:
	./node_modules/.bin/mocha test/e2e

test_e2e_sauce:
	SAUCE_JOB_ID=`git rev-parse --short HEAD` \
	SAUCE=1 make test_e2e

test_midway:
	./node_modules/.bin/mocha test/midway

test_midway_sauce_connect:
	SAUCE_JOB_ID=`git rev-parse --short HEAD` \
	SAUCE_CONNECT=1 make test_midway

.PHONY: \
	DEFAULT \
	test \
	test_e2e \
	test_e2e_sauce \
	test_midway \
	test_midway_sauce_connect
