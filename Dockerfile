FROM node:lts-bullseye

# Install system dependencies
RUN apt-get update && \
    apt-get install -y \
    ffmpeg \
    imagemagick \
    webp \
    build-essential \
    python3 \
    make \
    g++ \
    && apt-get upgrade -y \
    && npm install -g npm@latest pm2 \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy package files
COPY package.json yarn.lock* ./

# Install dependencies with retry logic
RUN yarn install --frozen-lockfile --production=true || \
    (yarn cache clean && yarn install --frozen-lockfile --production=true)

# Copy application files
COPY . .

# Health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD node healthcheck.js || exit 1

# Run application
CMD ["pm2-runtime", "start", "index.js", "--name", "atlas-md"]
