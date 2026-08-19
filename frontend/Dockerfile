# Stage 1: Build Flutter Web Application
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

# Copy dependency specifications first for layer caching
COPY pubspec.yaml pubspec.lock* ./
RUN flutter pub get

# Copy full Flutter source code
COPY . .

# Build production Web artifact
RUN flutter build web --release

# Stage 2: Production Nginx Server
FROM nginx:alpine

# Copy custom Nginx configuration
COPY frontend/nginx.conf /etc/nginx/conf.d/default.conf

# Copy compiled Flutter web assets
COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
