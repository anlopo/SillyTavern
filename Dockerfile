FROM node:lts-alpine3.18

# Arguments
ARG APP_HOME=/home/node/app

# Install system dependencies
#RUN apk add --no-cache gcompat tini git

# Install system dependencies with chromium headless
RUN apk upgrade --no-cache --available \
    && apk add --no-cache gcompat tini git \
      chromium-swiftshader ttf-freefont \
      font-noto-emoji \
    && apk add --no-cache \
      --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community \
      font-wqy-zenhei

# Font config for chromium headless
COPY local.conf /etc/fonts/local.conf

# ENVs for chromium headless and ST_SELENIUM
ENV CHROME_BIN=/usr/bin/chromium-browser \
    CHROME_PATH=/usr/lib/chromium/ \
    CHROMIUM_FLAGS="--disable-software-rasterizer --disable-dev-shm-usage" \
    ST_SELENIUM_BROWSER=chrome \
    ST_SELENIUM_HEADLESS=true \
    ST_SELENIUM_DEBUG=false

# Clean image
RUN rm -rf /usr/share/man /usr/share/doc /usr/share/info /var/cache/apk/*

# Ensure proper handling of kernel signals
ENTRYPOINT [ "tini", "--" ]

# Create app directory
WORKDIR ${APP_HOME}

# Set NODE_ENV to production
ENV NODE_ENV=production

# Install app dependencies
COPY package*.json post-install.js ./
RUN \
  echo "*** Install npm packages ***" && \
  npm i --no-audit --no-fund --quiet --omit=dev && npm cache clean --force

# Bundle app source
COPY . ./

# Copy default chats, characters and user avatars to <folder>.default folder
RUN \
  rm -f "config.yaml" || true && \
  ln -s "./config/config.yaml" "config.yaml" || true && \
  mkdir "config" || true

# Cleanup unnecessary files
RUN \
  echo "*** Cleanup ***" && \
  mv "./docker/docker-entrypoint.sh" "./" && \
  rm -rf "./docker" && \
  rm -rf "./Dockerfile" && \
  echo "*** Make docker-entrypoint.sh executable ***" && \
  chmod +x "./docker-entrypoint.sh" && \
  echo "*** Convert line endings to Unix format ***" && \
  dos2unix "./docker-entrypoint.sh"

EXPOSE 8000

CMD [ "./docker-entrypoint.sh" ]
