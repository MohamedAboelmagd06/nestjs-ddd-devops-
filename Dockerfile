
# Stage 1: Build the application
FROM node:22-alpine AS builder

WORKDIR /app

# Copy package files first to improve build caching
COPY package.json package-lock.json ./

# Install dependencies without running prepare scripts such as Lefthook
RUN npm ci --ignore-scripts

# Copy application source code
COPY . .

# Build NestJS application
RUN npm run build


# Stage 2: Production image
FROM node:22-alpine AS production

WORKDIR /app

ENV NODE_ENV=production

# Copy package files
COPY package.json package-lock.json ./

# Install production dependencies only
RUN npm ci --omit=dev --ignore-scripts

# Copy compiled application
COPY --from=builder /app/dist ./dist

# Copy database migrations
COPY --from=builder /app/src/config/database/migrations ./src/config/database/migrations

# Application port
EXPOSE 3000

# Start the application
CMD ["npm", "run", "start:prod"]
