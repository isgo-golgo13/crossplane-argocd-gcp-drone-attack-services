APP_NAME=cxpcli-drop

build:
	go build -o $(APP_NAME) main.go

run:
	go run main.go delete

fmt:
	go fmt ./...

vet:
	go vet ./...

docker:
	docker build -t $(APP_NAME):latest .

clean:
	rm -f $(APP_NAME)
