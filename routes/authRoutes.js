import express from 'express'
import { register, login, updateUser } from '../controller/authController.js'
import authenticator from '../middleware/auth.js'

const router = express.Router()

router.route('/register').post(register)
router.route('/login').post(login)
router.route('/update-user').patch(authenticator, updateUser)

export default router