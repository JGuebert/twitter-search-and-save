FROM node:19

COPY server /server

WORKDIR /server
RUN npm install

EXPOSE 3000
CMD ["node", "app.js"]
