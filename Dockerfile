# select base image to build our own customised node app microservice

FROM node as APP

# working directory inside the container

WORKDIR /usr/src/app

# copy dependencies

COPY package.json .

# Install npm

RUN npm install

# copy everything from current location to default location inside the container

COPY . .

#FROM node:alpine

#COPY --from=app /usr/src/app /usr/src/app
# This is the magic line that compresses the size

#WORKDIR /usr/src/app
# define the port

EXPOSE 3000

# start the app with CMD

CMD ["node","app.js"]

