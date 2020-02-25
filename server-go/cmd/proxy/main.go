package main

import (
	"context"
	"flag"
	"fmt"
	"log"
	"net"
	"net/http"

	"github.com/grpc-ecosystem/grpc-gateway/runtime"
	"google.golang.org/grpc"

	"github.com/thedahv/grpc-demo/pkg/services"
)

// https://github.com/grpc-ecosystem/grpc-gateway

var (
	grpcServiceEndpoint = flag.String("grpc-server-endpoint", "", "gRPC server endpoint")
)

func main() {
	flag.Parse()

	ctx := context.Background()
	ctx, cancel := context.WithCancel(ctx)
	defer cancel()

	// Register gRPC endpoint
	mux := runtime.NewServeMux()
	opts := []grpc.DialOption{grpc.WithInsecure()}
	fmt.Println("Endpoint at", *grpcServiceEndpoint)
	if err := services.RegisterPeopleHandlerFromEndpoint(ctx, mux, *grpcServiceEndpoint, opts); err != nil {
		log.Fatalf("could not register proxy endpoint: %v", err)
	}

	lis, err := net.Listen("tcp", ":0")
	if err != nil {
		log.Fatalf("failed to open port: %v", err)
	}
	log.Printf("listening on: %s", lis.Addr().String())
	if err := http.Serve(lis, mux); err != nil {
		log.Fatal(err)
	}
}
