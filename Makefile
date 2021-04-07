all: demo

.PHONY: setup
setup: 
	go run ./demo/setup/main.go

.PHONY: deploy
deploy: setup
		flow project deploy

.PHONY: demo
demo: deploy
		go run ./demo/main.go

.PHONY: test
test: deploy
		go run ./test/main.go