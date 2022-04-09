-include *.mk

.PHONY: clean format get upgrade outdated

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
