package main

import (
	"context"
	"log"
	"net"

	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func main() {
	log.Println("Booting up...")
	lis, err := net.Listen("tcp", ":0")
	if err != nil {
		log.Fatalf("failed to open port: %v", err)
	}

	log.Printf("listening on: %s", lis.Addr().String())
	s := grpc.NewServer()
	RegisterPeopleServer(s, &server{})
	if err := s.Serve(lis); err != nil {
		log.Fatalf("failed to start gRPC server: %v", err)
	}
}

// server implements the People gRPC service
type server struct {
	UnimplementedPeopleServer
}

var peopleIds = 1
var people = make(map[int]*Person)

// CreatePerson creates a new person and returns the message with the ID
// assigned. Returns an error if the name field is empty
func (s *server) Create(ct context.Context, req *CreateRequest) (*Person, error) {
	id := peopleIds

	person := req.GetPerson()
	if person.GetName() == "" {
		return nil, status.Error(codes.InvalidArgument, "person name required")
	}

	people[id] = person
	people[id].Id = int32(id)

	peopleIds++

	return people[id], nil
}

// FindPerson looks up a person by the ID defined in the LookupRequest and
// returns the Person. Returns an error if the ID is not in the datastore.
func (s *server) Find(ctx context.Context, req *LookupRequest) (*Person, error) {
	id := req.GetId()

	if person, ok := people[int(id)]; ok {
		return person, nil
	}

	return nil, status.Error(codes.NotFound, "no person found for that ID")
}

// List responds with all people in the data store in a single message.
func (s *server) List(context.Context, *ListRequest) (*ListResponse, error) {
	resp := &ListResponse{}
	for _, person := range people {
		resp.People = append(resp.People, person)
	}

	return resp, nil
}
