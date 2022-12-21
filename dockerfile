FROM node:19

COPY server /server

WORKDIR /server
RUN npm install

CMD ["node", "app.js"]
