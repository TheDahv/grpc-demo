GO_PROTO_FILES = ./server-go/*.pb.go
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

$(GO_PROTO_FILES): *.proto
	@protoc -I ./ ./person.proto --go_out=plugins=grpc:./server-go

$(RB_PROTO_FILES): *.proto
	@grpc_tools_ruby_protoc -I ./ --ruby_out=./entry-ruby/lib --grpc_out=./entry-ruby/lib ./person.proto

$(SUBDIRS):
	$(MAKE) -C $@
