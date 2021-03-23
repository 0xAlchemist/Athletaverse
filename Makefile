all: demo

.PHONY: deploy
deploy: 
		flow project deploy

.PHONY: demo
demo: deploy
		go run ./demo/main.go

