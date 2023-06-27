import express from 'express'
import dotenv from 'dotenv'
dotenv.config()

import connectDB from './db/connect.js'

// routers
import authRouter from './routes/authRoutes.js'
import jobRouter from './routes/jobRoutes.js'

// middleware
import notFoundMiddleware from './middleware/not-found.js'
import errorHandlerMiddleware from './middleware/error-handler.js'

const app = express()

const port = process.env.PORT || 4000

app.get('/api/v1/health', (req, res) => {
  res.send('ok')
})

app.use('/api/v1/auth', authRouter)
app.use('/api/v1/jobs', jobRouter)

app.use(notFoundMiddleware)
app.use(errorHandlerMiddleware)

const startServer = async () => {
  try {
    await connectDB(process.env.MONGO_URL)
    app.listen(port, () => {
      console.log(`Server is running on port ${port}`)
    })
  } catch (err) {
    console.log(err);
  }
}

startServer()