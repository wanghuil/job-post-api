import Job from '../models/Job.js'
import { BadRequestError, NotFoundError, UnAuthenticatedError } from '../errors/index.js'
import checkPermissions from '../utils/checkPermission.js'

const createJob = async (req, res) => {
  const { position, company } = req.body
  if(!position || !company) {
    return next(new BadRequestError('Fill all required fields'))
  }

  req.body.createdBy = req.user.userId;
  const job = await Job.create(req.body)

  res.status(201).json({ job })
}

const getAllJobs = async (req, res) => {
  const jobs = await Job.find({ createdBy: req.user.userId })

  res.status(200).json({ jobs, totalJob: jobs.length })
}

const updateJob = async (req, res) => {
  const { id: jobId } = req.params;
  const { position, company } = req.body 

  if(!position || !company) {
    return next(new BadRequestError('Fill all required fields'))
  }

  const job = await Job.findOne({ _id: jobId })
  if (!job) {
    throw new NotFoundError(`No job with id: ${jobId}`)
  }

  checkPermissions(req.user, job.createdBy)

  const updatedJob = await Job.findOneAndUpdate({ _id: jobId }, req.body, {
    new: true,
    runValidators: true,
  })

  res.status(200).json({ updatedJob });
}

const deleteJob = async (req, res) => {
  const { id: jobId } = req.params;

  const job = await Job.findOne({ _id: jobId })
  if (!job) {
    throw new NotFoundError(`No job with id: ${jobId}`)
  }

  checkPermissions(req.user, job.createdBy)

  await job.deleteOne();

  res.status(200).json({ msg: 'Success! Job removed' })
}

const showStats = (req, res) => {
  res.send('show stats')
}

export { createJob, getAllJobs, updateJob, deleteJob, showStats }