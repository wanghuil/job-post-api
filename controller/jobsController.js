const createJob = (req, res) => {
  res.send('create job')
}

const getAllJobs = (req, res) => {
  res.send('get jobs')
}

const updateJob = (req, res) => {
  res.send('update job')
}

const deleteJob = (req, res) => {
  res.send('delete job')
}

const showStats = (req, res) => {
  res.send('show stats')
}

export { createJob, getAllJobs, updateJob, deleteJob, showStats }