#!/bin/bash

RESOUR_COLLECS=$*

RESOUR_INDEX=0
for RC in ${RESOUR_COLLECS[*]}
do
  RC_ARR=(${RC//-/ })
  RESOUR[RESOUR_INDEX]=${RC_ARR[0]}
  COLLEC[RESOUR_INDEX]=${RC_ARR[1]}
  RES_LOWER[RESOUR_INDEX]=$(echo "$RESOUR" | sed -e 's/\(.*\)/\L\1/')
  RESOUR_INDEX=`expr $RESOUR_INDEX + 1`
done
RESOUR_INDEX=`expr $RESOUR_INDEX - 1`

ALL_RES=${RESOUR[0]}
if [ $RESOUR_INDEX -ge 1 ]
then
  for idx in $(seq 1 $RESOUR_INDEX)
  do
    ALL_RES="$ALL_RES, ${RESOUR[idx]}"
  done
fi

# Create index.js
cat >> index.js << EOF
const express = require('express');
const { port } = require('./.env').api;
const { errorHandler, notFoundHandler } = require('./middlewares');
const { $ALL_RES } = require('./routes');

const app = express();

app.use(express.json());

EOF

for idx in $(seq 0 $RESOUR_INDEX)
do
  cat >> index.js << EOF
app.use('/${COLLEC[idx]}', ${RESOUR[idx]});
EOF
done

cat >> index.js << EOF

app.use('/:notFound', notFoundHandler);
app.use(errorHandler);

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
    database: 'fill it up',
  },
  mongodbConnection: {
    protocol: 'mongodb',
    hostname: 'localhost',
    port: '27017',
    username: '',
    password: '',
    database: 'fill it up',
    search: 'retryWrites=true&w=majority',
  },
};
EOF

# Add .env.js to gitignore if it exists
if [ -f ".gitignore" ]
then
  cat >> ./.gitignore << EOF


# Private enviroment
.env.js
EOF
fi

# Create resource index for controllers
for RES in ${RESOUR[*]}
do
  cat >> ./controllers/index.js << EOF
const ${RES} = require('./${RES}');
EOF
done

cat >> ./controllers/index.js << EOF

module.exports = {
EOF

for RES in ${RESOUR[*]}
do
  cat >> ./controllers/index.js << EOF
  ${RES},
EOF
done

cat >> ./controllers/index.js << EOF
};
EOF

# Copy resource index pattern to similar directories 
DIRS=("services routes middlewares/validations schemas")
for DIR in ${DIRS[*]}
do
  cp ./controllers/index.js ./$DIR/index.js
done

# Create resources controllers
for RES in ${RESOUR[*]}
do
  cat > ./controllers/$RES.js << EOF
const Service = require('../services').$RES;
const tcw = require('../utils').tryCatchWrapper;

const findById = tcw(async (req, res, next) => {
  const { id } = req.params;
  const { result, error } = await Service.findById(id);
  if (error) return next(error);
  res.status(200).json(result);
});

const updateById = tcw(async (req, res, next) => {
  const { id } = req.params;
  const { result, error } = await Service.updateById(id, req.body);
  if (error) return next(error);
  res.status(200).json(result);
});

const deleteById = tcw(async (req, res, next) => {
  const { id } = req.params;
  const { result, error } = await Service.deleteById(id);
  if (error) return next(error);
  res.status(200).json(result);
});

const getAll = tcw(async (_req, res, next) => {
  const { result, error } = await Service.getAll();
  if (error) return next(error);
  res.status(200).json(result);
});

const insertOne = tcw(async (req, res, next) => {
  const { result, error } = await Service.insertOne(req.body);
  if (error) return next(error);
  res.status(201).json(result);
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

# Create resources middlewares/validations
for RES in ${RESOUR[*]}
do
  cat > ./middlewares/validations/$RES.js << EOF
const Schems = require('../../schemas').$RES;
const tcw = require('../../utils').tryCatchWrapper;

const options = { errors: { wrap: { label: "'" } } };

module.exports = (type) => tcw(async (req, _res, next) => {
  const schema = Schems[type];
  await schema.validateAsync(req.body, options);
  next();
}, 'badRequest');
EOF
done

# Create default middlewares
cat > ./middlewares/errorHandler.js << EOF
module.exports = (err, _req, res, _next) => {
  const { code, message } = err;
  const statusByErrorCode = {
    badRequest: 400,
    unauthenticated: 401,
    paymentRequired: 402,
    forbidden: 403,
    notFound: 404,
    alreadyExists: 409,
    internalError: 500,
  };
  const status = statusByErrorCode[code] || statusByErrorCode['internalError'];

  const resJson = () => {
    switch (code) {
      case 'notFound':
        return { message };
      case 'badRequest':
        return { error: { code, message: 'invalid data message', data: message } };
      default:
        return { error: { code, message } };
    }
  };

  res.status(status).json(resJson())
};
EOF

cat > ./middlewares/notFound.js << EOF
module.exports = (req, _res, next) => {
  const { notFound } = req.params;
  next({ code: 'notFound', message: \`Method: \${req.method} - Path: '/${notFound}' is not supported\` });
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
for idx in $(seq 0 $RESOUR_INDEX)
do
  cat > ./services/${RESOUR[idx]}.js << EOF
const { General } = require('../models');

const COLLECTION_NAME = '${COLLEC[idx]}';
const RESOURCE_NAME_SINGULAR = 'fill it up';

const getAll = async () => {
  const examples = await General.getAll(COLLECTION_NAME);
  return { result: examples };
};

const findById = async (id) => {
  const example = await General.findById(COLLECTION_NAME, id);
  if (!example) return { error: { code: 'notFound', message: 'notFound message find' } };
  return { result: example };
};

const insertOne = async (obj) => {
  const insertedId = await General.insertOne(COLLECTION_NAME, obj);
  if (!insertedId) return { error: { code: 'alreadyExists', message: 'alreadyExists message insert' } };
  return { result: { _id: insertedId, ...obj } };
};

const deleteById = async (id) => {
  const resp = await General.deleteById(COLLECTION_NAME, id);
  if (!resp) return { error: { code: 'notFound', message: 'notFound message delete' } };
  return { result: { message: \`The \${RESOURCE_NAME_SINGULAR} with id = \${id} was deleted successfully\` } };
};

const updateById = async (id, obj) => {
  const resp = await General.updateById(COLLECTION_NAME, id, obj);
  if (!resp) return { error: { code: 'notFound', message: 'notFound message update' } };
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
for RES in ${RESOUR[*]}
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
for RES in ${RESOUR[*]}
do
  cat > ./schemas/$RES.js << EOF
const Joi = require('joi');

const insert = Joi.object({
  label1: Joi.string().required(),
  label4: Joi.array().items(Joi.number()).required(),
  label2: Joi.string().isoDate().message('Date needs to be on ISODate pattern')
   .required(),
  label3: Joi.number().required(),
})
.messages({ 'any.required': 'The {#label} field is required.', 'string.type': '{#label} needs to be a string' });

const update = Joi.object({
  label1: Joi.string(),
  label4: Joi.array().items(Joi.number()),
  label2: Joi.string().isoDate().message('Date needs to be on ISODate pattern'),
  label3: Joi.number(),
});

module.exports = {
  insert,
  update,
};
EOF
done

# Create utils files
cat > ./utils/getURL.js << EOF
module.exports = ({ protocol, hostname, port, username, password, pathname, search, hash }) => {
  const host = username ? \`@\${hostname}\` : hostname;
  const pwd = password ? \`:\${password}\` : '';
  const portNumber = port ? \`:\${port}\` : '';
  const searchStr = search ? \`?\${search}\` : '';
  const hashStr = hash ? \`#\${hash}\` : '';

  return \`\${protocol}://\${username}\${pwd}\${host}\${portNumber}/\${pathname}\${hashStr}\${searchStr}\`;
};
EOF

cat > ./utils/tryCatchWrapper.js << EOF
module.exports = (callback, code = 'internalError') => async (req, res, next) => {
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