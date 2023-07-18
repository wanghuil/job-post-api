import bycrpt from 'bcryptjs';
import mongoose from "mongoose";
import validator from 'validator';
import jwt from 'jsonwebtoken';

const UserSchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, "Please provide a name"],
    minLength: 3,
    maxLength: 20,
    trim: true,
  },
  email: {
    type: String,
    validate: {
      validator: validator.isEmail,
      message: "Please provide valid email"
    },
    required: [true, "Please provide an email"],
    unique: true
  },
  password: {
    type: String,
    required: [true, "Please enter password"],
    minLength: 6,
    select: false
  }
})

UserSchema.pre('save', async function() {

  if (this.isModified('password')) {
    const salt = await bycrpt.genSalt(10);
    this.password = await bycrpt.hash(this.password, salt)
  }
})

UserSchema.methods.createJwt = function() {
  return jwt.sign({userId: this._id}, 'secret', {expiresIn: '1d'})
}

UserSchema.methods.comparePassword = async function(password) {
  const isMatch = await bycrpt.compare(password, this.password)
  return isMatch
}

export default mongoose.model('User', UserSchema)