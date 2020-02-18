const grpc = require('grpc');
const express = require('express');
const protoLoader = require('@grpc/proto-loader');

// Note, Node *does* support generating static code for clients and servers.
// See: https://github.com/grpc/grpc/tree/v1.27.0/examples/node/static_codegen
const PROTO_PATH = __dirname + '/../person.proto';

const packageDefinition = protoLoader.loadSync(
  PROTO_PATH,
  {
    keepCase: true,
    longs: String,
    enums: String,
    defaults: true,
    oneofs: true,
  });

const {
  People,
  Person,
  ListRequest,
  ListResponse
} = grpc.loadPackageDefinition(packageDefinition);


const app = express();
app.use(express.static('static'));

module.exports.start = ({ host }) => {
  if (!host) {
    throw new Error('grpc host address required');
  }

  const client = new People(host, grpc.credentials.createInsecure());
  app.get('/api/people', (req, res) => {
    const response = client.list({}, (err, people) => {
      if (err) { return res.status(500).json(res); }

      return res.json(people);
    });
  });

  const server = app.listen(0, (...args) => {
    console.log(`app listening on localhost:${server.address().port}`);
  });
};
