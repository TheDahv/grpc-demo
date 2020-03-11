# By default, protoc looks for protoc run-time files in the "include" folder
# adjacent to its installation path. You can also specify additional protoc
# files with arguments to protoc
PROTOC_PATH = $(shell which protoc)
PROTOC_DIR = $(shell dirname $(PROTOC_PATH))
PROTO_INCLUDE = "$(PROTOC_DIR)/include"

# Files generated for language-specific clients and servers
RB_PROTO_FILES = ./entry-ruby/lib/*_pb.rb
GO_PROTO_FILES = ./server-go/pkg/services/*.pb.go

# Files generated for the HTTP proxy
GO_GATEWAY_FILES = ./server-go/pkg/services/*.pb.gw.go
# Warning! Requires jq on your machine! Since Go dependencies are installed with
# "go mod", we need to find the local cache created by "go mod download"
# There is probably a cross-compat version of doing this but this is quick
# enough
GO_GATEWAY_PATH = $(shell cd ./server-go && go mod download -json github.com/grpc-ecosystem/grpc-gateway | jq -r .Dir )

SWAGGER_PROTO_DIR = $(GO_GATEWAY_PATH)/protoc-gen-swagger
SWAGGER_PROTO_INCLUDE_DIR = proto/protoc-gen-swagger
SWAGGER_PROTO_FILES = $(SWAGGER_PROTO_DIR)/options/*.proto

RB_SWAGGER_FILES = ./entry-ruby/lib/protoc-gen-swagger/options/*_pb.rb

SUBDIRS := node-app server-go

.PHONY = all build deps clean ruby_swagger_libs $(SUBDIRS)

all: build deps

# Descends into each sub-folder to run the service-specific build step there
build: $(SWAGGER_PROTO_INCLUDE_DIR) $(GO_PROTO_FILES) $(GO_GATEWAY_FILES) $(RB_PROTO_FILES) deps
	@for d in $(SUBDIRS); do \
		$(MAKE) -C $$d build ; \
	done

$(SWAGGER_PROTO_INCLUDE_DIR):
	@ln -s $(SWAGGER_PROTO_DIR) $(SWAGGER_PROTO_INCLUDE_DIR)

# Downloads any dependencies required in a given service-specific folder
deps:
	@for d in $(SUBDIRS); do \
		$(MAKE) -C $$d deps ; \
	done

clean:
	@for d in $(SUBDIRS); do \
		$(MAKE) -C $$d clean ; \
	done; \
  rm -f $(GO_PROTO_FILES) $(RB_PROTO_FILES) $(GO_GATEWAY_FILES)

# Generate any Go protobuf files based on protoc definitions to build the Go
# gRPC server
$(GO_PROTO_FILES): ./proto/*.proto
	@mkdir -p server-go/pkg/services && \
	protoc \
		-I ./proto \
  	-I $(GO_GATEWAY_PATH)/third_party/googleapis \
		--go_out=plugins=grpc:server-go/pkg/services/ \
		./proto/person.proto

# Builds the HTTP gateway. Since it borrows a lot of the same Go code as the Go
# gRPC server, it lives as a binary generated within the main project
$(GO_GATEWAY_FILES): ./proto/*.proto
	@mkdir -p server-go/cmd/proxy && \
	mkdir -p docs && \
	protoc \
		-I ./proto \
  	-I $(GO_GATEWAY_PATH)/third_party/googleapis \
		--grpc-gateway_out=logtostderr=true:server-go/pkg/services \
		--swagger_out=logtostderr=true:./docs \
		./proto/person.proto

# Generates the Ruby gRPC client to build the Ruby data entry app
$(RB_PROTO_FILES): ./proto/*.proto ruby_swagger_libs
	@mkdir -p entry-ruby/lib && \
	grpc_tools_ruby_protoc \
		-I ./proto \
		-I $(PROTO_INCLUDE) \
		-I $(SWAGGER_PROTO_DIR)/options \
		--grpc_out=entry-ruby/lib \
		--ruby_out=entry-ruby/lib \
		./proto/person.proto

ruby_swagger_libs: $(SWAGGER_PROTO_FILES)
	@mkdir -p entry-ruby/lib/protoc-gen-swagger/options
	@for f in $(SWAGGER_PROTO_FILES); do \
		grpc_tools_ruby_protoc \
			-I proto \
			-I $(SWAGGER_PROTO_DIR)/options \
			--ruby_out=entry-ruby/lib/protoc-gen-swagger/options \
			$$f ; \
	done
