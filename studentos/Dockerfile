# Official Flutter image (includes SDK, Android SDK, Java)
FROM ghcr.io/cirruslabs/flutter:stable

# Working directory inside container
WORKDIR /app

# Install common build tools required for some plugins and desktop/web builds
# No sudo needed because the image runs as root by default
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        clang \
        cmake \
        ninja-build \
        pkg-config \
        libgtk-3-dev \
        unzip \
        xz-utils \
    && rm -rf /var/lib/apt/lists/*

# Accept Android licenses (non-interactive)
RUN yes | flutter doctor --android-licenses || true

# Copy pubspec first to cache dependencies layer
COPY pubspec.* ./
RUN flutter pub get

# Copy the rest of the project
COPY . .

# Optional build argument: set to "true" to run an Android release build during image build
ARG BUILD_ANDROID="false"
ARG BUILD_WEB="false"

# Build steps (only executed when build args are true).  This keeps the image fast when used as a dev container.
RUN if [ "$BUILD_ANDROID" = "true" ]; then flutter build apk --release; fi \
    && if [ "$BUILD_WEB" = "true" ]; then flutter build web --release; fi

# Expose common dev ports (DevTools, web server, etc.)
EXPOSE 8080 9222

# Default command: start a shell. For interactive development mount your code and run commands inside the container.
CMD ["/bin/bash"]

# Usage examples (run locally):
# 1) Create an image (no build):
#    docker build -t studentos-dev .
# 2) Run a dev container and mount the working directory so edits reflect immediately:
#    docker run --rm -it -v "$(pwd)":/app -p 8080:8080 studentos-dev
# 3) Build an APK inside the image while building the image (produces apk in build/):
#    docker build --build-arg BUILD_ANDROID=true -t studentos-builder .
#    docker create --name temp studentos-builder
#    docker cp temp:/app/build/app/outputs/apk/release/app-release.apk ./
#    docker rm temp
