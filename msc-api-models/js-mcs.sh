#!/bin/bash

RESOURCES=($*)

DIRS_TO_MK=(controllers models services middlewares routes schemas utils)
for DIR in ${DIRS_TO_MK[*]}
do
  if [ ! -d "tests/unit/$DIR" ]
  then
    mkdir tests/unit/$DIR
  fi
done

UNIT_TESTS_DIR="./tests/unit"

for RES in ${RESOURCES[*]}
do
  # Create controllers tests
  CONTROLLER=$UNIT_TESTS_DIR/controllers/$RES
  mkdir $CONTROLLER

  ## Create controllers DeleteById test
  cat > $CONTROLLER/${RES}DeleteById.test.js << EOF
const sinon = require('sinon');
const { expect } = require('chai');

const Controller = require('../../../../controllers').$RES;
const Service = require('../../../../services').$RES;

describe('$RES controller: deleteById()', () => {
  const req = {};
  const res = {};
  const next = sinon.stub().returns();
  let result;
  let error;

  before(() => {
    req.params = { id: 'id' };
    res.status = sinon.stub().returns(res);
    res.json = sinon.stub().returns(undefined);
  });
  
  describe('when the Service throws an error', () => {
    before(() => {
      error = new Error('Server error');
      sinon.stub(Service, 'deleteById').throws(error);
    });

    after(() => {
      Service.deleteById.restore();
    });

    it('should call next with the error', async () => {
      await Controller.deleteById(req, res, next);

      expect(next.calledOnceWith({ code: 'internal_error', message: error.message })).to.be.true;
    });

  });

  describe('when the Service resolves { error }', () => {
    before(() => {
      error = { code: 'not_found', message: 'error message' };
      sinon.stub(Service, 'deleteById').resolves({ error });
    });

    after(() => {
      Service.deleteById.restore();
    });

    it('should call Service.deleteById with "id"', async () => {
      await Controller.deleteById(req, res, next);

      expect(Service.deleteById.calledOnceWith('id')).to.be.true;
    });

    it('should call once next error', async () => {
      await Controller.deleteById(req, res, next);

      expect(next.callCount).to.be.equals(3);
      expect(next.calledWith(error)).to.be.true;
    });
  });

  describe('when the Service resolves { result }', () => {
    before(() => {
      result = { id: 1};
      sinon.stub(Service, 'deleteById').resolves({ result });
    });

    after(() => {
      Service.deleteById.restore();
    });

    it('should call Service.deleteById with "id"', async () => {
      await Controller.deleteById(req, res, next);

      expect(Service.deleteById.calledOnceWith('id')).to.be.true;
    });

    it('should call res.status with 200', async () => {
      await Controller.deleteById(req, res, next);

      expect(res.json.callCount).to.be.equals(2);
      expect(res.status.calledWith(200)).to.be.true;
    });

    it('should call res.json with result', async () => {
      await Controller.deleteById(req, res, next);

      expect(res.json.callCount).to.be.equals(3);
      expect(res.json.calledWith(result)).to.be.true;
    });
  });
});
EOF

  ## Create controllers FindById test
  cat > $CONTROLLER/${RES}FindById.test.js << EOF
const sinon = require('sinon');
const { expect } = require('chai');

const Controller = require('../../../../controllers').$RES;
const Service = require('../../../../services').$RES;

describe('$RES controller: findById()', () => {
  const req = {};
  const res = {};
  const next = sinon.stub().returns();
  let result;
  let error;

  before(() => {
    req.params = { id: 'id' };
    res.status = sinon.stub().returns(res);
    res.json = sinon.stub().returns(undefined);
  });
  
  describe('when the Service throws an error', () => {
    before(() => {
      error = new Error('Server error');
      sinon.stub(Service, 'findById').throws(error);
    });

    after(() => {
      Service.findById.restore();
    });

    it('should call next with the error', async () => {
      await Controller.findById(req, res, next);

      expect(next.calledOnceWith({ code: 'internal_error', message: error.message })).to.be.true;
    });

  });

  describe('when the Service resolves { error }', () => {
    before(() => {
      error = { code: 'not_found', message: 'error message' };
      sinon.stub(Service, 'findById').resolves({ error });
    });

    after(() => {
      Service.findById.restore();
    });

    it('should call Service.findById with "id"', async () => {
      await Controller.findById(req, res, next);

      expect(Service.findById.calledOnceWith('id')).to.be.true;
    });

    it('should call once next error', async () => {
      await Controller.findById(req, res, next);

      expect(next.calledWith(error)).to.be.true;
    });
  });

  describe('when the Service resolves { result }', () => {
    before(() => {
      result = { id: 1};
      sinon.stub(Service, 'findById').resolves({ result });
    });

    after(() => {
      Service.findById.restore();
    });

    it('should call Service.findById with "id"', async () => {
      await Controller.findById(req, res, next);

      expect(Service.findById.calledOnceWith('id')).to.be.true;
    });

    it('should call res.status with 200', async () => {
      await Controller.findById(req, res, next);

      expect(res.json.callCount).to.be.equals(2);
      expect(res.status.calledWith(200)).to.be.true;
    });

    it('should call res.json with result', async () => {
      await Controller.findById(req, res, next);

      expect(res.json.callCount).to.be.equals(3);
      expect(res.json.calledWith(result)).to.be.true;
    });
  });
});
EOF

  ## Create controllers GetAll test
  cat > $CONTROLLER/${RES}GetAll.test.js << EOF
const sinon = require('sinon');
const { expect } = require('chai');

const Controller = require('../../../../controllers').$RES;
const Service = require('../../../../services').$RES;

describe('$RES controller: getAll()', () => {
  const req = {};
  const res = {};
  const next = sinon.stub().returns();
  let result;
  let error;

  before(() => {
    res.status = sinon.stub().returns(res);
    res.json = sinon.stub().returns(undefined);
  });

  describe('when the Service throws an error', () => {
    before(() => {
      error = new Error('Server error');
      sinon.stub(Service, 'getAll').throws(error);
    });

    after(() => {
      Service.getAll.restore();
    });

    it('should call next with the error', async () => {
      await Controller.getAll(req, res, next);

      expect(next.calledOnceWith({ code: 'internal_error', message: error.message })).to.be.true;
    });

  });

  describe('when the Service resolves { result }', () => {
    before(() => {
      result = [{ id: 1}];
      sinon.stub(Service, 'getAll').resolves({ result });
    });

    after(() => {
      Service.getAll.restore();
    });

    it('should call once res.status with 200', async () => {
      await Controller.getAll(req, res, next);

      expect(res.status.calledOnceWith(200)).to.be.true;
    });

    it('should call once res.json with result', async () => {
      await Controller.getAll(req, res, next);

      expect(res.json.callCount).to.be.equals(2);
      expect(res.json.calledWith(result)).to.be.true;
    });

  });
});
EOF

  ## Create controllers InsertOne test
  cat > $CONTROLLER/${RES}InsertOne.test.js << EOF
const sinon = require('sinon');
const { expect } = require('chai');

const Controller = require('../../../../controllers').$RES;
const Service = require('../../../../services').$RES;

describe('$RES controller: insertOne()', () => {
  const req = {};
  const res = {};
  const next = sinon.stub().returns();
  let result;
  let error;

  before(() => {
    req.body = { obj: 'any' };
    res.status = sinon.stub().returns(res);
    res.json = sinon.stub().returns(undefined);
  });

  describe('when the Service throws an error', () => {
    before(() => {
      error = new Error('Server error');
      sinon.stub(Service, 'insertOne').throws(error);
    });

    after(() => {
      Service.insertOne.restore();
    });

    it('should call next with the error', async () => {
      await Controller.insertOne(req, res, next);

      expect(next.calledOnceWith({ code: 'internal_error', message: error.message })).to.be.true;
    });

  });

  describe('when the Service resolves { error }', () => {
    before(() => {
      error = { code: 'already_exists', message: 'error message' };
      sinon.stub(Service, 'insertOne').resolves({ error });
    });

    after(() => {
      Service.insertOne.restore();
    });

    it('should call Service.insertOne with req.body', async () => {
      await Controller.insertOne(req, res, next);

      expect(Service.insertOne.calledOnceWith(req.body)).to.be.true;
    });

    it('should call next with error', async () => {
      await Controller.insertOne(req, res, next);

      expect(next.callCount).to.be.equals(3);
      expect(next.calledWith(error)).to.be.true;
    });
  });

  describe('when the Service resolves { result }', () => {
    before(() => {
      result = [{ id: 1}];
      sinon.stub(Service, 'insertOne').resolves({ result });
    });

    after(() => {
      Service.insertOne.restore();
    });

    it('should call once Service.insertOne with req.body', async () => {
      await Controller.insertOne(req, res, next);

      expect(Service.insertOne.calledOnceWith(req.body)).to.be.true;
    });

    it('should call res.status with 201', async () => {
      await Controller.insertOne(req, res, next);

      expect(res.status.callCount).to.be.equals(2);
      expect(res.status.calledWith(201)).to.be.true;
    });

    it('should call res.json with result', async () => {
      await Controller.insertOne(req, res, next);

      expect(res.json.callCount).to.be.equals(3);
      expect(res.json.calledWith(result)).to.be.true;
    });

  });
});
EOF

  ## Create controllers UpdateById test
  cat > $CONTROLLER/${RES}UpdateById.test.js << EOF
const sinon = require('sinon');
const { expect } = require('chai');

const Controller = require('../../../../controllers').$RES;
const Service = require('../../../../services').$RES;

describe('$RES controller: updateById()', () => {
  const req = {};
  const res = {};
  const next = sinon.stub().returns();
  let result;
  let error;

  before(() => {
    req.params = { id: 'id' };
    req.body = { obj: 'any' };
    res.status = sinon.stub().returns(res);
    res.json = sinon.stub().returns(undefined);
  });
  
  describe('when the Service throws an error', () => {
    before(() => {
      error = new Error('Server error');
      sinon.stub(Service, 'updateById').throws(error);
    });

    after(() => {
      Service.updateById.restore();
    });

    it('should call next with the error', async () => {
      await Controller.updateById(req, res, next);

      expect(next.calledOnceWith({ code: 'internal_error', message: error.message })).to.be.true;
    });

  });

  describe('when the Service resolves { error }', () => {
    before(() => {
      error = { code: 'not_found', message: 'error message' };
      sinon.stub(Service, 'updateById').resolves({ error });
    });

    after(() => {
      Service.updateById.restore();
    });

    it('should call Service.updateById with "id" and req.body', async () => {
      await Controller.updateById(req, res, next);

      expect(Service.updateById.calledOnceWith('id', req.body)).to.be.true;
    });

    it('should call next with error', async () => {
      await Controller.updateById(req, res, next);

      expect(next.callCount).to.be.equals(3);
      expect(next.calledWith(error)).to.be.true;
    });
  });

  describe('when the Service resolves { result }', () => {
    before(() => {
      result = { id: 1};
      sinon.stub(Service, 'updateById').resolves({ result });
    });

    after(() => {
      Service.updateById.restore();
    });

    it('should call Service.updateById with "id" and req.body', async () => {
      await Controller.updateById(req, res, next);

      expect(Service.updateById.calledOnceWith('id', req.body)).to.be.true;
    });

    it('should call res.status with 200', async () => {
      await Controller.updateById(req, res, next);

      expect(res.json.callCount).to.be.equals(2);
      expect(res.status.calledWith(200)).to.be.true;
    });

    it('should call res.json with result', async () => {
      await Controller.updateById(req, res, next);

      expect(res.json.callCount).to.be.equals(3);
      expect(res.json.calledWith(result)).to.be.true;
    });
  });
});
EOF

  # Create services tests
  SERVICE=$UNIT_TESTS_DIR/services/$RES
  mkdir $SERVICE

  ## Create services DeleteById test
  cat > $SERVICE/${RES}DeleteById.test.js << EOF
const sinon = require('sinon');
const { expect } = require('chai');

const Model = require('../../../../models').General;
const Service = require('../../../../services').$RES;

describe('$RES Service: deleteById()', () => {
  afterEach(async () => {
    Model.deleteById.restore();
  });

  describe('when the resource\`s _id does not exist', () => {
    beforeEach(async () => {
      sinon.stub(Model, 'deleteById').resolves(false);
    });
  

    describe('should return { error } with', () => {
      it('error.code === "not_found"', async () => {
        const { error } = await Service.deleteById();
        expect(error.code).to.be.equal('not_found');
      });

      it('error.message defined', async () => {
        const { error } = await Service.deleteById();
        expect(error.message).to.not.be.undefined;
      });
    });
  });

  describe('when the resource\`s _id exists', () => {
    beforeEach(() => {
      sinon.stub(Model, 'deleteById').resolves(true);
    });

    it('should return { result } where result is an object', async () => {
      const { result } = await Service.deleteById();
      expect(result).to.be.an('object');
    });
  });
});
EOF

  ## Create services FindById test
  cat > $SERVICE/${RES}FindById.test.js << EOF
const sinon = require('sinon');
const { expect } = require('chai');

const Model = require('../../../../models').General;
const Service = require('../../../../services').$RES;

let _id = 'randomId'; 

describe('$RES Service: findById()', () => {
  afterEach(async () => {
    Model.findById.restore();
  });

  describe('when the resource looked up does not exist', () => {
    beforeEach(async () => {
      sinon.stub(Model, 'findById').resolves(null);
    });
  

    describe('should return { error } with', () => {
      it('error.code === "not_found"', async () => {
        const { error } = await Service.findById(_id);
        expect(error.code).to.be.equal('not_found');
      });

      it('error.message defined', async () => {
        const { error } = await Service.findById(_id);
        expect(error.message).to.not.be.undefined;
      });
    });
  });

  describe('when the resource looked up exists', () => {
    beforeEach(() => {
      sinon.stub(Model, 'findById').resolves({ id: 1 });
    });

    it('should return { result } where result is an object', async () => {
      const { result } = await Service.findById(_id);
      expect(result).to.be.an('object');
    });
  });
});
EOF

  ## Create services GetAll test
  cat > $SERVICE/${RES}GetAll.test.js << EOF
const sinon = require('sinon');
const { expect } = require('chai');

const Model = require('../../../../models').General;
const Service = require('../../../../services').$RES;

describe('$RES Service: getAll()', () => {
  afterEach(async () => {
    Model.getAll.restore();
  });

  describe('when the collection has no item', () => {
    beforeEach(async () => {
      sinon.stub(Model, 'getAll').resolves([]);
    });
  

    it('should return object with a key result with an empty array', async () => {
      const resp = await Service.getAll();
      expect(resp.result).to.be.an('array');
      expect(resp.result.length).to.be.equal(0);
    });
  });

  describe('when the collection has 3 items', () => {
    beforeEach(() => {
      sinon.stub(Model, 'getAll').resolves([{ id: 1 },{ id: 2 },{ id: 3 }]);
    });

    it('should return an object with key result with 3 items', async () => {
      const resp = await Service.getAll();
      expect(resp.result).to.be.an('array');
      expect(resp.result.length).to.be.equal(3);
    });
  });
});
EOF

  ## Create services InsertOne test
  cat > $SERVICE/${RES}InsertOne.test.js << EOF
const sinon = require('sinon');
const { expect } = require('chai');

const Model = require('../../../../models').General;
const Service = require('../../../../services').$RES;

let _id = 'randomId'; 

describe('$RES Service: insertOne()', () => {
  afterEach(async () => {
    Model.insertOne.restore();
  });
  
  describe('when is passed a "resource" WITH an existing id', () => {
    beforeEach(async () => {
      sinon.stub(Model, 'insertOne').resolves(undefined);
    });

    describe('should return { error } with', () => {
      it('error.code === "already_exists"', async () => {
        const { error } = await Service.insertOne(_id);
        expect(error.code).to.be.equal('already_exists');
      });

      it('error.message defined', async () => {
        const { error } = await Service.insertOne(_id);
        expect(error.message).to.not.be.undefined;
      });
    });
  });

  describe('when is passed a "resource" WITHOUT an existing id', () => {
    beforeEach(() => {
      sinon.stub(Model, 'insertOne').resolves('id');
    });

    it('should return { result } where result is an object', async () => {
      const { result } = await Service.insertOne(_id);
      expect(result).to.be.an('object');
    });
  });
});
EOF

  ## Create services UpdateById test
  cat > $SERVICE/${RES}UpdateById.test.js << EOF
const sinon = require('sinon');
const { expect } = require('chai');

const Model = require('../../../../models').General;
const Service = require('../../../../services').$RES;

let _id = 'randomId';

describe('$RES Service: updateById()', () => {
  afterEach(async () => {
    Model.updateById.restore();
  });

  describe('when the resource\`s _id does not exist or doesn\`t change', () => {
    beforeEach(async () => {
      sinon.stub(Model, 'updateById').resolves(false);
    });
  

    describe('should return { error } with', () => {
      it('error.code === "not_found"', async () => {
        const { error } = await Service.updateById(_id, { id: 1 });
        expect(error.code).to.be.equal('not_found');
      });

      it('error.message defined', async () => {
        const { error } = await Service.updateById(_id, { id: 1 });
        expect(error.message).to.not.be.undefined;
      });
    });
  });

  describe('when the resource\`s _id exists and the object is modified', () => {
    beforeEach(() => {
      sinon.stub(Model, 'updateById').resolves(true);
      sinon.stub(Model, 'findById').resolves({ id: 1 });
    });

    afterEach(() => {
      Model.findById.restore();
    });

    it('should return { result } where result is an object', async () => {
      const { result } = await Service.updateById(_id, { id: 1 });
      expect(result).to.be.an('object');
    });
  });
});
EOF

done