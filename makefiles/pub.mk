.PHONY: get upgrade outdated clean

get:
	@dart pub get

upgrade: get
	@dart pub upgrade

outdated:
	@dart pub outdated --transitive --show-all --dev-dependencies --dependency-overrides

clean:
	@rm -rf coverage pubspec.lock .packages .dart_tool
