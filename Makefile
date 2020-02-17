GO_PROTO_FILES = ./server-go/*.pb.go

.PHONY = all clean

all: $(GO_PROTO_FILES) $(RB_PROTO_FILES)

$(GO_PROTO_FILES): *.proto
	@protoc -I ./ ./person.proto --go_out=plugins=grpc:./server-go

clean:
	 @rm -f $(GO_PROTO_FILES)
