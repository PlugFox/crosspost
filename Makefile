-include *.mk

.PHONY: clean format get upgrade outdated test coverage

clean:
	@rm -rf coverage pubspec.lock .packages .dart_tool

format:
	@dart fix --apply .
	@dart format -l 80 --fix .

get:
	@dart pub get

upgrade: get
	@dart pub upgrade

outdated:
	@dart pub outdated --transitive --show-all --dev-dependencies --dependency-overrides

test:
	@dart test --concurrency=6 --platform vm --coverage=coverage test/*

coverage: test
	@dart run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --packages=.packages --report-on=lib
	# @lcov --summary coverage/lcov.info
	@genhtml -o coverage coverage/lcov.info 