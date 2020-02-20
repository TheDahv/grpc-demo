.PHONY = build clean deps

NAME = server-go

SOURCES = *.go pkg/**/*.go

build: $(SOURCES)
	GO111MODULE=on go build -o $(NAME)

deps:
	GO111MODULE=on go mod download

clean:
	@rm -f grpc-demo \
	@rm -rf pkg/services
