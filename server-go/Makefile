.PHONY = build clean deps

NAME = server-go

SOURCES = *.go

build: $(SOURCES)
	GO111MODULE=on go build -o $(NAME)

deps:
	GO111MODULE=on go mod download

clean:
	@rm -f grpc-demo
