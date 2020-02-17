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

## Go [[link]](https://grpc.io/docs/quickstart/go/)

- Install gRPC: `go get -u google.golang.org/grpc`
- Install Go protoc plugin: `go get -u github.com/golang/protobuf/protoc-gen-go`

At this point, you also want to make sure your system knows where to find
binaries installed by Go. Add this to your system's environment configuration:

```
export PATH=$PATH:$GOPATH/bin
```
