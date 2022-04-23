.PHONY: codegen

codegen: get
	@dart run build_runner build --delete-conflicting-outputs --release
	@dart format -l 80 --fix .
