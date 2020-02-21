const express = require('express');
const googleProtos = require('google-proto-files');
const grpc = require('grpc');
const protoLoader = require('@grpc/proto-loader');

// Note, Node *does* support generating static code for clients and servers.
// See: https://github.com/grpc/grpc/tree/v1.27.0/examples/node/static_codegen
const PROTO_PATH = __dirname + '/../proto/person.proto';

// Since we're using Google's defined error packages, we want to have some
// access to their mapping of codes to status names. You can see theme here:
// https://github.com/googleapis/api-common-protos/blob/master/google/rpc/code.proto
//
// This also builds an object that you can compare to at run-time
const path = googleProtos.getProtoPath('rpc');
const codes =
  protoLoader.
    loadSync(`${path}/code.proto`)['google.rpc.Code'].
    type.
    value.
    reduce(
      ((memo, { name, number }) => Object.assign(memo, { [name]: parseInt(number, 10) })),
      {}
    );

// Now we read the person.proto file we wrote and Node.js will turn it into
// JavaScript code you can use for clients.
const packageDefinition = protoLoader.loadSync(
  PROTO_PATH,
  {
    keepCase: true,
    longs: String,
    enums: String,
    defaults: true,
    oneofs: true,
  });

// Here is the client to read People information!
const { People } = grpc.loadPackageDefinition(packageDefinition);

const app = express();
app.use(express.static('static'));

// We expose a function that will stand up the HTTP server, but it needs to know
// where the gRPC server is first
module.exports.start = ({ host }) => {
  if (!host) {
    throw new Error('grpc host address required');
  }

  const client = new People(host, grpc.credentials.createInsecure());
  app.get('/api/people/:personId', (req, res) => {
    client.find({ id: req.params.personId }, (err, { status, person } = {}) => {
      if (err || status.code !== codes.OK) {
        console.log({ err });
        // gRPC-core level error
        if (err) {
          return res.status(500).json({
            code: err.code,
            message: err.details,
          });
        }

        // application-level error
        return res.status(status.code === codes.NOT_FOUND ? 404 : 500).json(status);
      }

      res.json(person);
    });
  });

  app.get('/api/people', (req, res) => {
    client.list({}, (err, { status, people } = {}) => {
      if (err) { return res.status(500).json(err); }

      // We could parse all the errors here or just pass "status" through and
      // have the UI handle any errors
      //
      // Bear in mind, an application-level error will be represented in
      // 'status', but there are still gRPC-core errors that can happen --
      // network connectivity, timeouts, etc. -- that happen in layers lower
      // than our application code. A robust client will handle those too.
      return res.json(people);
    });
  });

  const server = app.listen(0, () => {
    console.log(`app listening on localhost:${server.address().port}`);
  });
};
