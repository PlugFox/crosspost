.PHONY: format pana

format:
	@dart fix --apply .
	@dart format -l 80 --fix .

pana:
	@dart pub global activate pana && pana --json --no-warning --line-length 80
