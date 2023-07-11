const errorHandlerMiddleware = (err, req, res, next) => {
  console.log(err.message)
  const defaultError = {
    statusCode: err.statusCode || 500,
    msg: err.message || 'Something is wrong, try later'
  }

  // handle validatorError
  if (err.name === 'ValidationError') {
    defaultError.statusCode = 400
    defaultError.msg = Object.values(err.errors).map(val => val.message).join('; ')
  }

  // // when 11000 code, return 400 badRequest error
  if (err.code && err.code === 11000) {
    defaultError.statusCode = 400
    defaultError.msg = `"${err.keyValue.email}" already exists. Please try another one`
  }
  res.status(defaultError.statusCode).send(defaultError.msg)
}

export default errorHandlerMiddleware