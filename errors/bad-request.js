import CustomeAPIError from './custom-api.js'

class BadRequestError extends CustomeAPIError {
  constructor(message) {
    super(message)
    this.statusCode = 400
  }
}

export default BadRequestError