package main

import (
	"context"
	"log"
	"net"

	"github.com/thedahv/grpc-demo/pkg/services"

	"google.golang.org/genproto/googleapis/rpc/code"
	"google.golang.org/genproto/googleapis/rpc/status"

	"google.golang.org/grpc"
)

func main() {
	log.Println("Booting up...")
	lis, err := net.Listen("tcp", ":0")
	if err != nil {
		log.Fatalf("failed to open port: %v", err)
	}

	log.Printf("listening on: %s", lis.Addr().String())
	s := grpc.NewServer()
	services.RegisterPeopleServer(s, &server{})
	if err := s.Serve(lis); err != nil {
		log.Fatalf("failed to start gRPC server: %v", err)
	}
}

// server implements the People gRPC service
type server struct {
	services.UnimplementedPeopleServer
}

var peopleIds = 1
var people = make(map[int]*services.Person)

// CreatePerson creates a new person and returns the message with the ID
// assigned. Returns an error if the name field is empty
func (s *server) Create(ct context.Context, req *services.CreateRequest) (*services.CreateResponse, error) {
	id := peopleIds

	person := req.GetPerson()
	resp := &services.CreateResponse{
		Status: &status.Status{
			Code:    0,
			Message: "",
			Details: nil,
		},
		Person: nil,
	}

	if person.GetName() == "" {
		resp.Status.Code = int32(code.Code_INVALID_ARGUMENT)
		resp.Status.Message = "person name required"
		return resp, nil
	}

	people[id] = person
	people[id].Id = int32(id)

	peopleIds++

	resp.Status.Code = int32(code.Code_OK)
	resp.Person = people[id]

	return resp, nil
}

// FindPerson looks up a person by the ID defined in the LookupRequest and
// returns the Person. Returns an error if the ID is not in the datastore.
func (s *server) Find(ctx context.Context, req *services.LookupRequest) (*services.LookupResponse, error) {
	id := req.GetId()

	resp := &services.LookupResponse{
		Status: &status.Status{
			Code:    0,
			Message: "",
			Details: nil,
		},
		Person: nil,
	}

	if id == 0 {
		resp.Status.Code = int32(code.Code_INVALID_ARGUMENT)
		resp.Status.Message = "ID required"
		return resp, nil
	}

	if person, ok := people[int(id)]; ok {
		resp.Status.Code = int32(code.Code_OK)
		resp.Person = person
		return resp, nil
	}

	resp.Status.Code = int32(code.Code_NOT_FOUND)
	resp.Status.Message = "no person found for that ID"

	return resp, nil
}

// List responds with all people in the data store in a single message.
func (s *server) List(context.Context, *services.ListRequest) (*services.ListResponse, error) {
	resp := &services.ListResponse{
		Status: &status.Status{
			Code:    0,
			Message: "",
			Details: nil,
		},
		People: nil,
	}

	for _, person := range people {
		resp.People = append(resp.People, person)
	}

	resp.Status.Code = int32(code.Code_OK)
	return resp, nil
}
