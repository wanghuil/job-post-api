# Use the official Node.js image as base
FROM node:16

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json to the working directory
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code to the working directory
COPY . .

# Set the MONGO_URL environment variable
#ENV MONGO_URL="mongodb://host.docker.internal:27017/job-post"
ARG MONGODB_SECRET
ENV MONGO_URL="mongodb+srv://wli:${MONGODB_SECRET}@land-tasker.gcovzya.mongodb.net/?retryWrites=true&w=majority"

# Expose the port your application is listening on (if applicable)
ENV PORT="3000"
EXPOSE 3000

# Start the application
CMD ["npm", "start"]
