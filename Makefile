# Flutter commands for different environments

.PHONY: dev prod build-dev-ios build-prod-ios build-dev-android build-prod-android clean

# Run commands
dev:
	flutter run -t lib/main_dev.dart

prod:
	flutter run -t lib/main_prod.dart

# Build commands for iOS
build-dev-ios:
	flutter build ios -t lib/main_dev.dart --dart-define=ENVIRONMENT=dev

build-prod-ios:
	flutter build ios -t lib/main_prod.dart --dart-define=ENVIRONMENT=prod

# Build commands for Android
build-dev-android:
	flutter build apk -t lib/main_dev.dart --dart-define=ENVIRONMENT=dev

build-prod-android:
	flutter build apk -t lib/main_prod.dart --dart-define=ENVIRONMENT=prod

# Build release APK
build-dev-release:
	flutter build apk --release -t lib/main_dev.dart --dart-define=ENVIRONMENT=dev

build-prod-release:
	flutter build apk --release -t lib/main_prod.dart --dart-define=ENVIRONMENT=prod

# Clean
clean:
	flutter clean

# Get dependencies
get:
	flutter pub get

# Run tests
test:
	flutter test

# Analyze code
analyze:
	flutter analyze

# Format code
format:
	dart format .