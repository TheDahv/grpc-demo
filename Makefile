GO_PROTO_FILES = ./server-go/*.pb.go
RB_PROTO_FILES = ./entry-ruby/*.pb.rb

.PHONY = all clean

all: $(GO_PROTO_FILES) $(RB_PROTO_FILES)

$(GO_PROTO_FILES): *.proto
	@protoc -I ./ ./person.proto --go_out=plugins=grpc:./server-go

$(RB_PROTO_FILES): *.proto
	@grpc_tools_ruby_protoc -I ./ --ruby_out=./entry-ruby/lib --grpc_out=./entry-ruby/lib ./person.proto

clean:
	 @rm -f $(GO_PROTO_FILES) $(RB_PROTO_FILES)
