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
#ENV MONGO_URL="mongodb://host.docker.internal:27017"
ENV MONGO_URL="mongodb://127.0.0.1:27017"

# Expose the port your application is listening on (if applicable)
EXPOSE 4000

# Start the application
CMD ["npm", "start"]
