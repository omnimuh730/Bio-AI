FROM node:18-alpine
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm install --silent --no-update-notifier --no-audit --progress=false
COPY . .
EXPOSE 3001
CMD ["npm", "run", "dev"]
