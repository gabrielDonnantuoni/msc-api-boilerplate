#!/bin/bash

# Create models connection
cat > ./models/connection.js << EOF
const { MongoClient } = require('mongodb');
const { mongodbConnection } = require('../.env');
const { getURL } = require('../utils');

const OPTIONS = { useNewUrlParser: true, useUnifiedTopology: true };

let db = null;

const connection = () => {
  return db ? Promise.resolve(db)
  : MongoClient.connect(getURL(mongodbConnection), OPTIONS)
    .then((conn) => {
      db = conn.db(mongodbConnection.database);
      return db;
    })
    .catch((err) =>{
      console.log(err);
      process.exitCode = 1;
    });
}

module.exports = connection;
EOF

# Create models General
cat > ./models/General.js << EOF
const { ObjectId } = require('mongodb');
const connection = require('./connection');

const withCollection = async (collecName) => await connection().then((db) => db.collection(collecName));

const getAll = async (collecName) => (
  await withCollection(collecName)
    .then((coll) => coll.find().toArray())
);

const findById = async (collecName, id) => (
  await withCollection(collecName)
    .then((coll) => coll.findOne(new ObjectId(id)))
);

const insertOne = async (collecName, obj) => {
  try {
    const { insertedId } = await withCollection(collecName)
      .then((coll) => coll.insertOne(obj));
    return insertedId;
  } catch (err) {
    return undefined;
  }
};

const deleteById = async (collecName, id) => {
  const { deletedCount } = await withCollection(collecName)
    .then((coll) => coll.deleteOne({ _id: new ObjectId(id) }));
  if (!deletedCount) return false;
  return true;
};

const updateById = async (collecName, id, obj) => {
  const { modifiedCount } = await withCollection(collecName)
    .then((coll) => coll.updateOne(
      { _id: new ObjectId(id)},
      { \$set: { ...obj } }
    ));
  if (!modifiedCount) return false;
  return true;
};

module.exports = {
  getAll,
  findById,
  insertOne,
  deleteById,
  updateById,
};
EOF