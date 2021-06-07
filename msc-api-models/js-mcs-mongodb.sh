#!/bin/bash

UNIT_TESTS_DIR="./tests/units"

# Create models tests
MODEL=$UNIT_TESTS_DIR/models/General
mkdir $MODEL

## Create models DeleteById test
cat > $MODEL/GeneralDeleteById.test.js << EOF
const sinon = require('sinon');
const { expect } = require('chai');
const { MongoClient, ObjectId } = require('mongodb');
const { MongoMemoryServer } = require('mongodb-memory-server');

const Model = require('../../../../models').General;
const { database } = require('../../../../.env').mongodbConnection;

let DBServer;
let connectionMock;
let db;
let _id;

describe('Generals Model: deleteById()', () => {
  before(async () => {
    DBServer = new MongoMemoryServer();
    const URLMock = await DBServer.getUri();

    connectionMock = await MongoClient
      .connect(URLMock, {
        useNewUrlParser: true,
        useUnifiedTopology: true
    });

    db = connectionMock.db(database);
    
    sinon.stub(MongoClient, 'connect').resolves(connectionMock);
  });

  after(async () => {
    MongoClient.connect.restore();
    if (connectionMock) connectionMock.close();
    if (DBServer) await DBServer.stop()
  });

  describe('when the resource\`s _id does not exist', () => {
    it('should return false', async () => {
      const resp = await Model.deleteById('collection', new ObjectId());
      expect(resp).to.be.false;
    });
  });

  describe('when the resource\`s _id exists', () => {
    beforeEach(async () => {
      const { insertedId } = await db.collection('collection').insertOne({ id: 1 });
      _id = insertedId;
    });

    afterEach(async () => {
      await db.collection('collection').deleteMany({});
    });

    it('should return true', async () => {
      const resp = await Model.deleteById('collection', new ObjectId(_id));
      expect(resp).to.be.true;
    });

  });
});
EOF

## Create models FindById test
cat > $MODEL/GeneralFindById.test.js << EOF
const sinon = require('sinon');
const { expect } = require('chai');
const { MongoClient, ObjectId } = require('mongodb');
const { MongoMemoryServer } = require('mongodb-memory-server');

const Model = require('../../../../models').General;
const { database } = require('../../../../.env').mongodbConnection;

let DBServer;
let connectionMock;
let db;
let _id;

describe('Generals Model: findById()', () => {
  before(async () => {
    DBServer = new MongoMemoryServer();
    const URLMock = await DBServer.getUri();

    connectionMock = await MongoClient
      .connect(URLMock, {
        useNewUrlParser: true,
        useUnifiedTopology: true
    });

    db = connectionMock.db(database);
    
    sinon.stub(MongoClient, 'connect').resolves(connectionMock);
  });

  after(async () => {
    MongoClient.connect.restore();
    if (connectionMock) connectionMock.close();
    if (DBServer) await DBServer.stop()
  });

  describe('when the resource looked up does not exist', () => {
    it('should return null', async () => {
      const resp = await Model.findById('collection', new ObjectId());
      expect(resp).to.be.null;
    });
  });

  describe('when the resource looked up exists', () => {
    beforeEach(async () => {
      const { insertedId } = await db.collection('collection').insertOne({ id: 1 });
      _id = insertedId;
    });

    afterEach(async () => {
      await db.collection('collection').deleteMany({});
    });

    it('should return the resource object', async () => {
      const resp = await Model.findById('collection', new ObjectId(_id));
      expect(resp).to.be.an('object');
      expect(resp._id).to.be.eql(_id);
    });
  });
});
EOF

## Create models GetAll test
cat > $MODEL/GeneralGetAll.test.js << EOF
const sinon = require('sinon');
const { expect } = require('chai');
const { MongoClient } = require('mongodb');
const { MongoMemoryServer } = require('mongodb-memory-server');

const Model = require('../../../../models').General;
const { database } = require('../../../../.env').mongodbConnection;

let DBServer;
let connectionMock;
let db;

describe('Generals Model: getAll()', () => {
  before(async () => {
    DBServer = new MongoMemoryServer();
    const URLMock = await DBServer.getUri();

    connectionMock = await MongoClient
      .connect(URLMock, {
        useNewUrlParser: true,
        useUnifiedTopology: true
    });

    db = connectionMock.db(database);
    
    sinon.stub(MongoClient, 'connect').resolves(connectionMock);
  });

  after(async () => {
    MongoClient.connect.restore();
    if (connectionMock) connectionMock.close();
    if (DBServer) await DBServer.stop()
  });

  describe('when the collection has no item', () => {
    it('should return an empty array', async () => {
      const resp = await Model.getAll('collection');
      expect(resp).to.be.an('array');
      expect(resp.length).to.be.equal(0);
    });
  });

  describe('when the collection has 3 items', () => {
    beforeEach(async () => {
      await db.collection('collection').insertMany([{ id: 1 },{ id: 2 },{ id: 3 }]);
    });

    afterEach(async () => {
      await db.collection('collection').deleteMany({});
    });

    it('should return an array with 3 objects', async () => {
      const resp = await Model.getAll('collection');
      expect(resp).to.be.an('array');
      expect(resp.length).to.be.equal(3);
      expect(resp[0]).to.be.an('object');
    });
  });
});
EOF

## Create models InsertOne test
cat > $MODEL/GeneralInsertOne.test.js << EOF
const sinon = require('sinon');
const { expect } = require('chai');
const { MongoClient, ObjectId } = require('mongodb');
const { MongoMemoryServer } = require('mongodb-memory-server');

const Model = require('../../../../models').General;
const { database } = require('../../../../.env').mongodbConnection;

let DBServer;
let connectionMock;
let db;
let id;

describe('Generals Model: insertOne()', () => {
  before(async () => {
    DBServer = new MongoMemoryServer();
    const URLMock = await DBServer.getUri();

    connectionMock = await MongoClient
      .connect(URLMock, {
        useNewUrlParser: true,
        useUnifiedTopology: true
    });

    db = connectionMock.db(database);
    
    sinon.stub(MongoClient, 'connect').resolves(connectionMock);
  });

  after(async () => {
    MongoClient.connect.restore();
    if (connectionMock) connectionMock.close();
    if (DBServer) await DBServer.stop()
  });

  describe('when is passed a "resource" WITH an existing id', () => {
    beforeEach(async () => {
      const { insertedId } = await db.collection('collection').insertOne({ id: 1 });
      id = insertedId;
    });

    it('should return undefined', async () => {
      const resp = await Model.insertOne('collection', { _id: new ObjectId(id) });
      expect(resp).to.be.undefined;
    });
  });

  describe('when is passed a "resource" WITHOUT an existing id', () => {
    it('should return an id', async () => {
      const resp = await Model.insertOne('collection', { id: 1 });
      expect(resp).to.not.be.undefined;
    });
  });
});
EOF

## Create models UpdateById test
cat > $MODEL/GeneralUpdateById.test.js << EOF
const sinon = require('sinon');
const { expect } = require('chai');
const { MongoClient, ObjectId } = require('mongodb');
const { MongoMemoryServer } = require('mongodb-memory-server');

const Model = require('../../../../models').General;
const { database } = require('../../../../.env').mongodbConnection;

let DBServer;
let connectionMock;
let db;
let _id;

describe('Generals Model: updateById()', () => {
  before(async () => {
    DBServer = new MongoMemoryServer();
    const URLMock = await DBServer.getUri();

    connectionMock = await MongoClient
      .connect(URLMock, {
        useNewUrlParser: true,
        useUnifiedTopology: true
    });

    db = connectionMock.db(database);
    
    sinon.stub(MongoClient, 'connect').resolves(connectionMock);
  });

  after(async () => {
    MongoClient.connect.restore();
    if (connectionMock) connectionMock.close();
    if (DBServer) await DBServer.stop()
  });

  describe('when the resource\`s _id does not exist', () => {
    it('should return false', async () => {
      const resp = await Model.updateById('collection', new ObjectId(), { id: 1 });
      expect(resp).to.be.false;
    });
  });

  describe('when the resource\`s _id exists', () => {
    beforeEach(async () => {
      const { insertedId } = await db.collection('collection').insertOne({ id: 1 });
      _id = insertedId;
    });

    afterEach(async () => {
      await db.collection('collection').deleteMany({});
    });

    describe('when the resource is not modified', () => {
      it('should return false', async () => {
        const resp = await Model.updateById('collection', new ObjectId(_id), { id: 1 });
        expect(resp).to.be.false;
      });
    });

    describe('when the resource is modified', () => {
      it('should return true', async () => {
        const resp = await Model.updateById('collection', new ObjectId(_id), { id: 2 });
        expect(resp).to.be.true;
      });
    });

  });
});
EOF