# syntax=docker/dockerfile:1
# check=error=true

# This Dockerfile is designed for production, not development. Build and run a single container:
# docker build -t vesker .
# docker run -d -p 80:80 -p 443:443 -v vesker-storage:/rails/storage \
#   -e SECRET_KEY_BASE=<random> -e HOST=album.example.com \
#   -e SMTP_ADDRESS=... -e SMTP_USER_NAME=... -e SMTP_PASSWORD=... \
#   --name vesker vesker
# The -v volume keeps the SQLite databases AND uploaded photos across redeploys; HOST drives
# both the app's host config and Thruster's TLS certificate (see bin/docker-entrypoint).

# For a containerized dev environment, see Dev Containers: https://guides.rubyonrails.org/getting_started_with_devcontainer.html

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=4.0.1
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

# Rails app lives here
WORKDIR /rails

# Install base packages. libvips handles image variants + HEIC EXIF (built with libheif);
# ffmpeg (ffprobe) provides video duration, poster frames, and capture-time extraction.
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl ffmpeg libjemalloc2 libvips sqlite3 && \
    ln -s /usr/lib/$(uname -m)-linux-gnu/libjemalloc.so.2 /usr/local/lib/libjemalloc.so && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Set production environment variables and enable jemalloc for reduced memory usage and latency.
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test" \
    LD_PRELOAD="/usr/local/lib/libjemalloc.so"

# Throw-away build stage to reduce size of final image
FROM base AS build

# Install packages needed to build gems and node modules (xz-utils unpacks the Node tarball)
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libvips libyaml-dev pkg-config unzip xz-utils && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Install Node.js for the Vite asset build (matches .node-version / the dev toolchain — npm, not bun)
ENV PATH=/usr/local/node/bin:$PATH
ARG NODE_VERSION=24.15.0
RUN mkdir -p /usr/local/node && \
    ARCH="$(dpkg --print-architecture | sed 's/amd64/x64/')" && \
    curl -fsSL "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-${ARCH}.tar.xz" | \
    tar -xJ -C /usr/local/node --strip-components=1

# Install application gems
COPY vendor/* ./vendor/
COPY Gemfile Gemfile.lock ./

RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    # -j 1 disable parallel compilation to avoid a QEMU bug: https://github.com/rails/bootsnap/issues/495
    bundle exec bootsnap precompile -j 1 --gemfile

# Install node modules
COPY package.json package-lock.json ./
RUN npm ci

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times.
# -j 1 disable parallel compilation to avoid a QEMU bug: https://github.com/rails/bootsnap/issues/495
RUN bundle exec bootsnap precompile -j 1 app/ lib/

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile


RUN rm -rf node_modules


# Final stage for app image
FROM base

# Run and own only the runtime files as a non-root user for security
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash
USER 1000:1000

# Copy built artifacts: gems, application
COPY --chown=rails:rails --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --chown=rails:rails --from=build /rails /rails

# Entrypoint prepares the database.
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Start server via Thruster by default, this can be overwritten at runtime
EXPOSE 80
CMD ["./bin/thrust", "./bin/rails", "server"]
