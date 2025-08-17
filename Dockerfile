# Step 1: Base image (Flutter official image from CirrusLabs)
FROM ghcr.io/cirruslabs/flutter:3.22.2

# Step 2: Set working directory
WORKDIR /lib

# Step 3: Copy pubspec and get dependencies first (caching layer)
COPY pubspec.* ./
RUN flutter pub get

# Step 4: Copy source code
COPY . .

# Step 5: Build release APK
RUN flutter build apk --release

# Step 6: Output APK path
CMD ["bash", "-c", "echo '✅ Build Complete! Find APK at: build/app/outputs/flutter-apk/app-release.apk' && ls -lh build/app/outputs/flutter-apk/"]
