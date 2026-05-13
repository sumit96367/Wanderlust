# Stage 1
FROM node:22 AS backend-builder

# setup the working dir
WORKDIR /app

# code
COPY package*.json ./

# packages install
RUN npm install --legacy-peer-deps

# copy the rest of the code
COPY . .

RUN chmod -R +x node_modules/.bin

# tests
RUN npm run test

# Stage 2
FROM node:22-slim

# setup the working dir
WORKDIR /app

# copy the above stage as compressed
COPY --from=backend-builder /app .

COPY .env.docker .env

# Port
EXPOSE 8080

# App
CMD ["npm", "start"]
