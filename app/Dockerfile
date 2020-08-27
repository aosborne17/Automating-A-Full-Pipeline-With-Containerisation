# This means we wont have to do install node or npm
FROM node AS app

# Define our working directory inside the container

WORKDIR /usr/src/app

# Copy the dependencies into the container

COPY package*.json ./

# install npm

RUN npm install



# from the current folder we want to copy everything into the working location of the container
COPY . .

# Second stage of our build to production - multi stage Docker build

FROM node:alpine

# We want to copy only essential things to this layer

# This is the magic line that compressess the size and still provides full functionality
# The application was lowered from 1GB to 150MB, a reduction of 85%
# 
COPY --from=app /usr/src/app /usr/src/app

# Define the work directory for the second stage build
WORKDIR /usr/src/app


# Expose the port in which we will run the application

EXPOSE 3000

# CMD ["node", "seeds/seed.js", "start", "node", "app.js"]

CMD ["node", "app.js"]

