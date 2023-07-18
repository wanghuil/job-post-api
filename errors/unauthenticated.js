import CustomeAPIError from './custom-api.js'

class UnAuthenticatedError extends CustomeAPIError {
  constructor(message) {
    super(message)
    this.statusCode = 401
  }
}

export default UnAuthenticatedError