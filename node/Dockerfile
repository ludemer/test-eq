FROM node:18-alpine
ENV NODE_ENV=test
WORKDIR /node_modules
ADD  node_modules  .
WORKDIR /src
COPY ["package.json", "package-lock.json*", "./"]
RUN npm install 
CMD ["node", "index.js"]
EXPOSE 8081/TCP
