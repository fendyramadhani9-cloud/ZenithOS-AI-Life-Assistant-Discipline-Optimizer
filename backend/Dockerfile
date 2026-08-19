FROM node:20-alpine

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm install --production

# Copy source files
COPY src/ ./src/

# Expose backend port
EXPOSE 3000

ENV PORT=3000
ENV NODE_ENV=production

CMD ["node", "src/index.js"]
