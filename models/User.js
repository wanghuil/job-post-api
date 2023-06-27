import mongoose from "mongoose";
import validator from 'validator';

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
    minLength: 6
  }
})

export default mongoose.model('User', UserSchema)