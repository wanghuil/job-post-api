import User from '../models/User.js'
import { BadRequestError, NotFoundError, UnAuthenticatedError } from '../errors/index.js'

const register = async (req, res, next) => {
  // extract form fields from body
  const { email, name, password } = req.body

  if (!name || !email || !password) {
    return next(new BadRequestError('Fill all required fields'))
  }

  // check unique of email
  const userExists = await User.findOne({ email })
  if (userExists) {
    return next(new BadRequestError(`${email} already exists`))
  }

  // Use Mongoose to create a DB record
  try {
    const user = await User.create(req.body)
    const token = user.createJwt()
    res.status(201).json({ user: {
      email: user.email,
      name: user, name
    }, token})
  } catch (error) {
    next(error)
  }
}

const login = async (req, res, next) => {
  // get email password
  const { email, password } = req.body
  if (!email || !password) {
    return next(new BadRequestError('Fill all required fields')) 
  }

  // get user info from db
  const user = await User.findOne({ email }).select('+password')
  if (!user) {
    return next(new NotFoundError(`Cannot find ${email}`))
  }

  // check password
  const isPasswordCorrect = await user.comparePassword(password)
  console.log(isPasswordCorrect);
  if (!isPasswordCorrect) {
    return next(new UnAuthenticatedError('Password incorrect'))
  }

  user.password = undefined
  // return user info to frontend with JWT token
  const token = user.createJwt()
  res.status(200).json({ user, token })
}

const updateUser = async (req, res) => {
  const { name, password } = req.body

  const user = await User.findOne({ _id: req.user.userId })

  user.name = name ?? user.name

  if (password) {
    user.password = password
  }

  await user.save()

  res.status(200).json( {msg: 'update success'})
}

export { register, login, updateUser }