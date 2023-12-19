.PHONY:	run

run:
	docker run -v $(shell pwd):/work -p 4000:4000 --rm -i -t blog

build:
	docker build --rm -t blog .
