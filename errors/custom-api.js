class CustomeAPIError extends Error {
  constructor(message, statusCode) {
    super(message)
  }
}

export default CustomeAPIError