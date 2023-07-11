import CustomeAPIError from './custom-api.js'

class NotFoundError extends CustomeAPIError {
  constructor(message) {
    super(message)
    this.statusCode = 404
  }
}

export default NotFoundError