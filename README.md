# Pre-Requisites

## Protocol Buffers

Installs the `protoc` compiler that other language plugins will use to generate
services and clients.

Go to the [protobufs releases
page](https://github.com/protocolbuffers/protobuf/releases) and download a zip
file for your system and architecture.

For example, a Linux user wanting to install version 3.11.4 would download
`protoc-3.11.4-linux-x86_64.zip` and a Mac user would download
`protoc-3.11.4-osx-x86_64.zip`.

Unzip this to a place where you can access the files and navigate there to the
newly uncompressed directory.

Find a directory on your system that you can add to your system's `$PATH`. For
example, I have `export PATH=~/bin:$PATH` in my `.zshrc` file.

Let's call that `$MY_BIN` for this setup guide

**Note:** this is a placeholder for documentation purposes; do not copy and
paste `$MY_BIN` as it probably does not exist in your computer. You are meant to
replace it with the path to the folder on your personal computer).

Move the contents of the zip file such that you have this:

- `cp -r ./include $MY_BIN/include`
- `cp ./bin/protoc $MY_BIN/protoc`

## gRPC

## Ruby [[link]](https://grpc.io/docs/quickstart/ruby/)

- Install the gem: `gem install grpc`
- Install the Ruby protoc plugin: `gem install grpc-tools`

## Go [[link]](https://grpc.io/docs/quickstart/go/)

- Install gRPC: `go get -u google.golang.org/grpc`
- Install Go protoc plugin: `go get -u github.com/golang/protobuf/protoc-gen-go`

At this point, you also want to make sure your system knows where to find
binaries installed by Go. Add this to your system's environment configuration:

```
export PATH=$PATH:$GOPATH/bin
```

# Running the Examples

## Server

This example includes a simple gRPC server in Go that allows a client to create,
look up, and list people. It stores people in a simple in-memory datastore.

To boot it up:

- Navigate into `./server-go`
- Run `go build`
- Run `./grpc-demo`

This will bind to a random free port and print out the address. Copy this port
for later.

## Data Entry Client

This example includes a simple Ruby CLI app to help record new people
information and send it to the Go server for storage.

To use it, remember the port value from the example in the previous system;
we'll reference it as `$PORT` below and you will need to replace it with your
value:

- Navigate to `entry-ruby`
- Run `./entry-app localhost:$PORT`

It will prompt you for people information to store.

To stop the program, press `Ctrl+C`.
