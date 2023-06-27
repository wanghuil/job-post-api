import User from '../models/User.js'

const register = (req, res) => {
  res.status(201).json( {msg: 'Created success'})
}

const login = (req, res) => {
  res.status(200).json( {msg: 'login success'})
}

const updateUser = (req, res) => {
  res.status(200).json( {msg: 'update success'})
}

export { register, login, updateUser }