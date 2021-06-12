#!/bin/bash

ROOT_DIR_AND_RESOURCES=($*)

RDR_LENGTH=${#ROOT_DIR_AND_RESOURCES[*]}
ROOT_DIR=${ROOT_DIR_AND_RESOURCES[0]}

MAX_IDX=`expr ${RDR_LENGTH} - 1`
for idx in $(seq 1 $MAX_IDX)
do
  RES_IDX=`expr $idx - 1`
  RESOURCES[$RES_IDX]=${ROOT_DIR_AND_RESOURCES[idx]}
done

ALL_RES=${RESOURCES[0]}
if [ ${#RESOURCES[*]} -ge 2 ]
then
  MAX_IDX=`expr ${#RESOURCES[*]} - 1`
  for idx in $(seq 1 $MAX_IDX)
  do
    ALL_RES="$ALL_RES, ${RESOURCES[idx]}"
  done
fi

# Create app.js
cat > app.js << EOF
const express = require('express');
const { errorHandler, notFoundHandler } = require('./middlewares');
const { $ALL_RES } = require('./routes');
const { resources } = require('./.env');

const app = express();

app.use(express.json());

EOF

for RES in ${RESOURCES[*]}
do
  cat >> app.js << EOF
app.use(\`/\${resources.${RES}.basePath}\`, ${RES});
EOF
done

cat >> app.js << EOF

app.use('/:notFound', notFoundHandler);
app.use(errorHandler);

module.exports = app;
EOF

# Create server.js
cat > server.js << EOF
const app = require('./app');
const { port } = require('./.env').api;

app.listen(port, () => console.log(\`App running on PORT: \${port}\`));
EOF

# Create .env.js
cat > .env.js << EOF
module.exports = {
  api: {
    protocol: 'http',
    hostname: 'localhost',
    port: 3001,
    username: '',
    password: '',
    pathname: '',
  },
  mysqlConnection: {
    host: 'localhost',
    user: '',
    password: '',
    database: 'fill_it_up',
  },
  mongodbConnection: {
    protocol: 'mongodb',
    hostname: 'localhost',
    port: '27017',
    username: '',
    password: '',
    database: 'fill_it_up', // fill it!
    search: 'retryWrites=true&w=majority',
  },
  resources: {
EOF

for RES in ${RESOURCES[*]}
do
  cat >> .env.js << EOF
    ${RES}: {
      singular: 'res_name_on_singular',
      basePath: 'path',
      tableOrCollec: 'table_or_collection_name',
      insertMocks: [ //insert at least two examples
        {
          key1: 'value1',
          key2: 'value2',
          key3: 'value3',
          key4: 'value4',
        },
        {
          key1: 'value1',
          key2: 'value2',
          key3: 'value3',
          key4: 'value4',
        },
      ],
    },
EOF
done

cat >> .env.js << EOF
  },
};
EOF

# Create resource index for controllers
for RES in ${RESOURCES[*]}
do
  cat >> ./controllers/index.js << EOF
const ${RES} = require('./${RES}');
EOF
done

cat >> ./controllers/index.js << EOF

module.exports = {
EOF

for RES in ${RESOURCES[*]}
do
  cat >> ./controllers/index.js << EOF
  ${RES},
EOF
done

cat >> ./controllers/index.js << EOF
};
EOF

# Copy resource index pattern to similar directories 
DIRS=("services routes schemas")
for DIR in ${DIRS[*]}
do
  cp ./controllers/index.js ./$DIR/index.js
done

# Create resources controllers
for RES in ${RESOURCES[*]}
do
  cat > ./controllers/$RES.js << EOF
const Service = require('../services').$RES;
const tcw = require('../utils').tryCatchWrapper;

const STATUS_OK = 200;
const STATUS_CREATED = 201;

const findById = tcw(async (req, res, next) => {
  const { id } = req.params;
  const { result, error } = await Service.findById(id);
  if (error) return next(error);
  res.status(STATUS_OK).json(result);
});

const updateById = tcw(async (req, res, next) => {
  const { id } = req.params;
  const { result, error } = await Service.updateById(id, req.body);
  if (error) return next(error);
  res.status(STATUS_OK).json(result);
});

const deleteById = tcw(async (req, res, next) => {
  const { id } = req.params;
  const { result, error } = await Service.deleteById(id);
  if (error) return next(error);
  res.status(STATUS_OK).json(result);
});

const getAll = tcw(async (_req, res, next) => {
  const { result, error } = await Service.getAll();
  if (error) return next(error);
  res.status(STATUS_OK).json(result);
});

const insertOne = tcw(async (req, res, next) => {
  const { result, error } = await Service.insertOne(req.body);
  if (error) return next(error);
  res.status(STATUS_CREATED).json(result);
});

module.exports = {
  getAll,
  findById,
  updateById,
  deleteById,
  insertOne,
};
EOF
done

# Create default middlewares
cat > ./middlewares/validations.js << EOF
const Schemas = require('../schemas');
const tcw = require('../utils').tryCatchWrapper;

const options = { errors: { wrap: { label: '\'' } } };

const validate = (resource) => (type) => tcw(async (req, _res, next) => {
  const schema = Schemas[resource][type];
  await schema.validateAsync(req.body, options);
  next();
}, 'bad_request');

module.exports = {
EOF

for RES in ${RESOURCES[*]}
do
  cat >> ./middlewares/validations.js << EOF
  $RES: validate('$RES'),
EOF
done

cat >> ./middlewares/validations.js << EOF
};
EOF

cat > ./middlewares/errorHandler.js << EOF
module.exports = (err, _req, res, _next) => {
  const { code, message } = err;
  const statusByErrorCode = {
    bad_request: 400,
    unauthenticated: 401,
    payment_required: 402,
    forbidden: 403,
    not_found: 404,
    already_exists: 409,
    unprocessable_entity: 422,
    internal_error: 500,
  };
  const status = statusByErrorCode[code] || statusByErrorCode['internal_error'];

  const resJson = () => {
    switch (code) {
    case 'bad_request':
      return { error: { code, message: 'invalid_data', data: message } };
    default:
      return { error: { code, message } };
    }
  };

  res.status(status).json(resJson());
};
EOF

cat > ./middlewares/notFound.js << EOF
module.exports = (req, _res, next) => {
  const { notFound } = req.params;
  next({
    code: 'not_found',
    message: \`Method: \${req.method} - Path: '/\${notFound}' is not supported\`,
  });
};
EOF

cat > ./middlewares/index.js << EOF
const errorHandler = require('./errorHandler');
const notFoundHandler = require('./notFound');
const validations = require('./validations');

module.exports = {
  errorHandler,
  notFoundHandler,
  validations,
};
EOF

# Create resources services
for RES in ${RESOURCES[*]}
do
  cat > ./services/${RES}.js << EOF
const { General } = require('../models');
const { resources: { ${RES} } } = require('../.env');

const getAll = async () => {
  const resources = await General.getAll(${RES}.tableOrCollec);
  return { result: resources };
};

const findById = async (id) => {
  const resource = await General.findById(${RES}.tableOrCollec, id);
  if (!resource) return { error: {
    code: 'not_found', message: \`\${${RES}.singular} not found\` } };
  return { result: resource };
};

const insertOne = async (obj) => {
  const insertedId = await General.insertOne(${RES}.tableOrCollec, obj);
  if (!insertedId) return { error: {
    code: 'already_exists', message: \`\${${RES}.singular} already exists\` } };
  return { result: { _id: insertedId, ...obj } };
};

const deleteById = async (id) => {
  const resp = await General.deleteById(${RES}.tableOrCollec, id);
  if (!resp) return { error: {
    code: 'not_found', message: 'not_found message delete' } };
  return { result: {
    message: \`The \${${RES}.singular} with id = \${id} was deleted successfully\` } };
};

const updateById = async (id, obj) => {
  const resp = await General.updateById(${RES}.tableOrCollec, id, obj);
  if (!resp) return { error: {
    code: 'not_found', message: \`\${${RES}.singular} not found\` } };
  return await findById(id);
};

module.exports = {
  getAll,
  findById,
  insertOne,
  deleteById,
  updateById,
};
EOF
done

# Create resources routes
for RES in ${RESOURCES[*]}
do
  cat > ./routes/$RES.js << EOF
const express = require('express');
const Controller = require('../controllers').$RES;
const isBodyValidFor = require('../middlewares/validations').$RES;
const { notFoundHandler } = require('../middlewares/');

const route = express.Router();

route.get('/:id', Controller.findById);

route.put('/:id', isBodyValidFor('update'), Controller.updateById);

route.delete('/:id', Controller.deleteById);

route.get('/', Controller.getAll);

route.post('/', isBodyValidFor('insert'), Controller.insertOne);

route.use('/:notFound', notFoundHandler);

module.exports = route;
EOF
done

# Create resources schemas
for RES in ${RESOURCES[*]}
do
  cat > ./schemas/$RES.js << EOF
const Joi = require('joi');

const insert = Joi.object({
  fill_it_up: Joi.string().required(),
  label2: Joi.string().isoDate().message('Date needs to be on ISODate pattern')
    .required(),
  label3: Joi.number().required(),
  label4: Joi.array().items(Joi.number()).required(),
})
  .messages({
    'any.required': 'The {#label} field is required.',
    'string.type': '{#label} needs to be a string',
  });

const update = Joi.object({
  label1: Joi.string(),
  label2: Joi.string().isoDate().message('Date needs to be on ISODate pattern'),
  label3: Joi.number(),
  label4: Joi.array().items(Joi.number()),
});

module.exports = {
  insert,
  update,
};
EOF
done

# Create utils files
cat > ./utils/getURL.js << EOF
module.exports = ({ protocol, hostname, port, username,
  password, pathname, search, hash }) => {
  const host = username ? \`@\${hostname}\` : hostname;
  const pwd = password ? \`:\${password}\` : '';
  const portNumber = port ? \`:\${port}\` : '';
  const searchStr = search ? \`?\${search}\` : '';
  const hashStr = hash ? \`#\${hash}\` : '';

  return \`\${protocol}://\${username}\${pwd}\${host}\${portNumber}/\${pathname}\${hashStr}\${searchStr}\`;
};
EOF

cat > ./utils/tryCatchWrapper.js << EOF
module.exports = (callback, code = 'internal_error') => async (req, res, next) => {
  try {
    await callback(req, res, next);
  } catch (err) {
    next({ code, message: err.message });
  }
};
EOF

cat > ./utils/index.js << EOF
const tryCatchWrapper = require('./tryCatchWrapper');
const getURL = require('./getURL');

module.exports = {
  tryCatchWrapper,
  getURL,
};
EOF

# Create models index
cat > ./models/index.js << EOF
const General = require('./General');

module.exports = {
  General,
};
EOF