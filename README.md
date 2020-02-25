# Overview

gRPC describes a few things:

- a strategy for building HTTP servers and clients
- an alternative to REST for specifying named behaviors
- an approach for enforcing consistency of message types and requirements
- an RPC framework that can work in any environment and in many programming languages

In this case, it is helpful to specify the difference between gRPC and an
important related concept: protobufs.

You can read a bit more about gRPC [in their
documentation](https://grpc.io/docs/guides/), but an RPC server exposes
functionality by named procedures -- or functions -- that a client in a remote
process can invoke over a network.

The notion of defining and exposing functionality across a network with gRPC is
not unique or new:

- [SOAP](https://en.wikipedia.org/wiki/SOAP) and [WSDL](https://www.w3.org/TR/wsdl.html)
- [JSON-RPC](https://www.jsonrpc.org/)
- [Apache Thrift](https://thrift.apache.org/)

RPC usually comes with a language that lets the programmer:

- specify the procedures that make up the service
- specify the messages that serve as inputs and outputs for a procedure
- support a program that can encode and decode a message into an interchange format

One such interchange format is
[protobuf](https://developers.google.com/protocol-buffers/docs/overview) which
was developed by Google and integrates nicely with gRPC.

"Interchange formats" aren't really a big deal -- they're just how we encode
(aka "serialize" or "marshall") and decode (aka "deserialize" or "unmarshall")
data before it is sent over the network. There are formats that you're familiar
with:

- XML
- JSON
- CSV

There are even other formats designed for RPC frameworks:
- [Capn Proto](https://capnproto.org/): built by original protobufs author and
  designed for parsing performance and message size
- [Flatbuffers](https://github.com/google/flatbuffers): built by Google and
  optimized for memory efficiency

You're already used to the idea of using different ways to get data into a
network request. Some key properties among interchange formats come from
whether they are binary or not:

- human readable: whether a human can understand the encoded data without a
  special tool
- streamable: whether a program can parse data as it arrives or
  wait for the entire payload before it can parse

This demo focuses on gRPC as an introduction to what you can do in general and
what you can do specifically with the gRPC ecosystem to build systems from
holistic and battle-tested components.

**DISCLAIMER:** I am not a gRPC expert or advocate by any means. I wanted to
learn more about this space and gRPC is where I started.

# Motivations

There are many features and advantages to motivate an exploration into gRPC.
This will focus on a few primary goals:

- consistency of data: knowing your client is sending data to a service with
  the correct shape, and knowing exactly what kind of data you will get back --
  _before_ shipping to production or writing a test.
- portability across languages: automatically generate clients in many popular
  programming languages that can communicate with a server built in any other
  language
- documentation: automatically generate documentation from the service and
  message definitions that is always up to date
- HTTP proxies: adoption might be hard if REST and JSON are probably already
  parts of your system, but the gRPC community has typically thought of
  everything. This demo comes with an HTTP proxy that automatically builds its own
  documentation and is always up to date with the gRPC server

# What We Won't Cover

This is limited to an introduction for programmers familiar with REST and JSON
over HTTP. It focuses on integration and consistency across programs and languages.

However there are many important concepts supported in gRPC that are worth
exploring but that we won't get to cover here. If you decide to explore
further, consider starting with:

- API design and idempotency
- authentication and end-to-end security
- retry behavior
- synchronous vs asynchronous services
- client, server, and bi-directional message streaming
- response codes and error messages
- deadlines, timeouts, and cancellations

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

gRPC comes built-in with some default error codes and statuses. Meanwhile, there's Google.

Turns out they've seen an error or two and have opinions. They've built and
shared an extension to protocol buffers that is indendent of any RPC
implementation. You can read about it
[here](https://grpc.io/docs/guides/error/). We've included it in our project via
Google's [api-common-protos](https://github.com/googleapis/api-common-protos).

This needs to live adjacent to the installation path for `protoc` in the
`include/google` folder.

Here are some steps to get these files into your computer:

- `cd $(dirname $(which protoc))/include`
- `git clone https://github.com/googleapis/api-common-protos.git`
- `mv api-commmon-protos/google/* google`
- `rm -r api-common-protos`

## Ruby [[link]](https://grpc.io/docs/quickstart/ruby/)

- Install the gem: `gem install grpc`
- Install the Ruby protoc plugin: `gem install grpc-tools`

Also be aware of the `googleapis-common-protos` Gem. It's meant to allow Ruby to
use Ruby implementations of Google's `api-common-protos` in your programs. But
the program also seems to not need it. Ruby is admittedly the environment I know
the least about.

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

## Web App

This example includes a small Node.js server and associated web UI to fetch and
list People results.

To use it, remember the port value from the example in the Go server; we'll
reference it as `$PORT` below and you will need to replace it with your value:

- Navigate to `node-app`
- Run `./run-app localhost:$PORT`

## Proxy

Not everyone is going to want to use gRPC, ok? REST and JSON are easy to learn
and get up and running, and has risen as a popular data interchange format. The
gRPC ecosystem has put together proxies that help translate between clients that
expect REST and JSON and services built with gRPC.

This project demonstrates building a Node service to provide JSON to a
JavaScript web app by calling out to a gRPC server, but it also ships a
stand-alone REST API via the
[`grpc-gateway`](https://github.com/grpc-ecosystem/grpc-gateway) project.

To run the proxy:

- Boot the gRPC server if you haven't already and copy its port (referenced as
  `$PORT` in the documentation)
- Navigate to `server-go/cmd/proxy/`
- Run `go build`
- Run `./proxy -grpc-server-endpoint localhost:$PORT`

It will print its address which you should be able to interact with. Try using
tools like `curl` to hit a few endpoints.

# Tools and Further Reading

**Other Concepts**:

- https://github.com/grpc/grpc/blob/master/doc/load-balancing.md
- https://github.com/grpc/grpc-web

**Tools**:

- https://www.npmjs.com/package/ts-protoc-gen
- https://github.com/grpc-ecosystem/awesome-grpc
- HTTP/JSON proxy to gRPC endpoints
  - https://www.envoyproxy.io/docs/envoy/v1.5.0/api-v1/http_filters/grpc_json_transcoder_filter.html#config-http-filters-grpc-json-transcoder-v1
  - https://github.com/grpc-ecosystem/grpc-gateway
- Protoc styleguide linter: https://github.com/ckaznocha/protoc-gen-lint
- CLI and clients
  - https://github.com/njpatel/grpcc
  - https://github.com/jnewmano/grpc-json-proxy

**Tips, Tricks, and Lessons Learned**

- "Best Practices for (Go) gRPC Services" [[video](https://www.youtube.com/watch?v=Z_yD7YPL2oE)]
- https://www.bugsnag.com/blog/using-grpc-in-production
- https://grpc.io/blog/
- https://dzone.com/articles/moving-from-apache-thrift-to-grpc-a-perspective-fr

**Error Handling**

Communicating errors and handling is actually really important! It lets us build
resilient and scalable systems while giving us the ability to figure out what
the heck is going on.

You should keep reading and watching because there is a lot to learn!

- ["Yes, No, Maybe? Error Handling with gRPC
  Examples"](https://www.youtube.com/watch?v=g44zR3cyC-I&t=1708s) Conference
  Talk
- [Google Cloud Errors](https://cloud.google.com/apis/design/errors#error_model)
