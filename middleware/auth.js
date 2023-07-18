import jwt from 'jsonwebtoken'
import { UnAuthenticatedError } from '../errors/index.js'

const auth = async (req, res, next) => {
  console.log('auth working');
  const headers = req.headers
  const authHeader = headers.authorization

  if (!authHeader) {
    return next(new UnAuthenticatedError('Authentication invalid'))
  }

  const token = authHeader.split(' ')[1]
  console.log(token);

  try {
    const payload = jwt.verify(token, 'secret')
    req.user = {userId: payload.userId}
  } catch (error) {
    console.log(error);
    return next(new UnAuthenticatedError('invalid token'))
  }
  next()
}

export default auth