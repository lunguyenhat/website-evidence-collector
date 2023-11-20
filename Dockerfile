# Website Evidence Collector running in a tiny Alpine Docker container
#
# Usage:
#
# build from source code folder: docker build -t website-evidence-collector .
# run container with e.g.:
# docker run --rm -it --cap-add=SYS_ADMIN -v $(pwd)/output:/output \
#   website-evidence-collector http://example.com/about
# If you hit the Error: EACCES: permission denied,
# then try "mkdir output && chown 1000 output"

FROM alpine:3.15.0

ARG UID=1010
ARG GID=1010

# Installs latest Chromium (77) package.
RUN apk add --no-cache \
      chromium \
      nss \
      freetype \
      freetype-dev \
      harfbuzz \
      ca-certificates \
      ttf-freefont \
      nodejs \
      yarn~=1.22 \
# Packages linked to testssl.sh
      bash procps drill coreutils libidn curl \
# Toolbox for advanced interactive use of WEC in container
      parallel jq grep aha

# Add user so we don't need --no-sandbox and match first linux uid 1000
RUN addgroup --system --gid $GID nextjs \
      && adduser --system --uid $UID --ingroup nextjs --shell /bin/bash nextjs \
      && mkdir -p /output \
      && chown -R nextjs:nextjs /output

COPY . /opt/website-evidence-collector/

# Install Testssl.sh
RUN curl -SL https://github.com/drwetter/testssl.sh/archive/refs/tags/v3.0.6.tar.gz | \
      tar -xz --directory /opt

# Run everything after as non-privileged user.
USER nextjs

WORKDIR /home/nextjs

# Tell Puppeteer to skip installing Chrome. We'll be using the installed package.
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true

RUN yarn global add file:/opt/website-evidence-collector --prefix /home/nextjs

# Let Puppeteer use system Chromium
ENV PUPPETEER_EXECUTABLE_PATH /usr/bin/chromium-browser

ENV PATH="/home/nextjs/bin:/opt/testssl.sh-3.0.6:${PATH}"
# Let website evidence collector run chrome without sandbox
# ENV WEC_BROWSER_OPTIONS="--no-sandbox"
# Configure default command in Docker container
ENTRYPOINT ["/home/nextjs/bin/website-evidence-collector"]
WORKDIR /
VOLUME /output