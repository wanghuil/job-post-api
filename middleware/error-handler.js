const errorHandlerMiddleware = (err, req, res, next) => {
  console.log(err)
  res.status(500).send('Error!')
}

export default errorHandlerMiddleware