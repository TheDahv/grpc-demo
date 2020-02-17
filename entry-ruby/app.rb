require 'person_pb'
require 'person_services_pb'

class App
  def initialize(args)
    @service_host, _rest = args
    raise "service_host argument required" unless @service_host

    @stub = People::Stub.new(@service_host, :this_channel_is_insecure)
  end

  def start
    while true do
      print "What's the name? "
      name = STDIN.gets.chomp

      print "Do they have experience? "
      input = STDIN.gets
      has_experience = !(input.chomp.downcase =~ /yes/).nil?

      create_person name, has_experience
    end
  end

  def create_person(name, has_experience)
    msg = CreateRequest.new(
      person: Person.new(
        name: name,
        has_grpc_experience: has_experience
      )
    )

    resp = @stub.create(msg)
    puts resp
  end
end
