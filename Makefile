# Makefile for Notematic (Flutter app)
# Usage examples:
#   make run-linux
#   make run-web
#   make run-android               # uses the first available device/emulator
#   make run-android DEVICE=emulator-5554
#   make start-emulator            # launches first available AVD
#   make build-android             # builds release AAB
#   make build-linux
#   make build-web
#   make build-all
#   make clean

SHELL := /usr/bin/bash

.PHONY: help run-linux run-web run-android start-emulator build-android build-linux build-web build-all clean aab \
        build_all build_linux build_web build_android list-emulators list-devices doctor-android

help:
	@echo "Available targets:"
	@echo "  run-linux           - Run app on Linux desktop"
	@echo "  run-web             - Run app on Chrome (web)"
	@echo "  run-android         - Run app on Android (use DEVICE=<id> to specify)"
	@echo "  start-emulator      - Start first available Android emulator (use AVD=<name> to specify)"
	@echo "  build-android       - Build Android App Bundle (.aab) release"
	@echo "  build-linux         - Build Linux release"
	@echo "  build-web           - Build Web release"
	@echo "  build-all           - Build Linux, Web and Android (AAB)"
	@echo "  clean               - Flutter clean and pub get"
	@echo "  list-emulators      - List available Flutter emulators"
	@echo "  list-devices        - List connected devices"
	@echo "  doctor-android      - Flutter doctor (Android diagnostics)"

list-emulators:
	flutter emulators

list-devices:
	flutter devices

doctor-android:
	flutter doctor -v

# --- Run targets ---
run-linux:
	flutter run -d linux

run-web:
	flutter run -d chrome

run-web-google-auth:
	flutter run -d chrome --web-hostname localhost --web-port 7357

run-android:
	@if [ -n "$(DEVICE)" ]; then \
		flutter run -d $(DEVICE); \
	else \
		flutter run; \
	fi

# Start Android emulator (requires Android SDK). Uses AVD env var if provided.
start-emulator: flutter emulators --launch Medium_Phone_API_36

# --- Build targets ---
# Preferred aliases per user's convention
build-all: build-linux build-web build-android

build-linux:
	flutter build linux --release

build-web:
	flutter build web --release

# Android release AAB
build-android: aab

aab:
	flutter build appbundle --release

clean:
	flutter clean && flutter pub get

# --- Underscore aliases (user preference) ---
build_all: build-all
build_linux: build-linux
build_web: build-web
build_android: build-android


