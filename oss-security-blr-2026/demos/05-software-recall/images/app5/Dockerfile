FROM node:20-alpine
WORKDIR /app
COPY package.json index.js ./
RUN npm install --omit=dev
CMD ["node", "index.js"]
