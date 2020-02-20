GO_PROTO_FILES = ./server-go/pkg/services/*.pb.go
RB_PROTO_FILES = ./entry-ruby/*.pb.rb

SUBDIRS := node-app server-go

.PHONY = all build deps clean $(SUBDIRS)

all: build deps

build: $(GO_PROTO_FILES) $(RB_PROTO_FILES) deps
	@for d in $(SUBDIRS); do \
		$(MAKE) -C $$d build ; \
	done

deps:
	@for d in $(SUBDIRS); do \
		$(MAKE) -C $$d deps ; \
	done

clean:
	@for d in $(SUBDIRS); do \
		$(MAKE) -C $$d clean ; \
	done; \
  rm -f $(GO_PROTO_FILES) $(RB_PROTO_FILES)

$(GO_PROTO_FILES): ./proto/*.proto
	@mkdir -p server-go/pkg/services && \
	protoc \
		-I ./proto \
		--go_out=plugins=grpc:server-go/pkg/services/ \
		./proto/person.proto

$(RB_PROTO_FILES): ./proto/*.proto
	@mkdir -p entry-ruby/lib && \
	grpc_tools_ruby_protoc \
		-I ./proto \
		--grpc_out=entry-ruby/lib \
		--ruby_out=entry-ruby/lib \
		./proto/person.proto

$(SUBDIRS):
	$(MAKE) -C $@
