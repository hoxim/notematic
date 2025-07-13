# Makefile - development commands for Flutter Rust Bridge project

# Generate Flutter Rust Bridge code
frb-gen:
	flutter_rust_bridge_codegen generate -r crate::api -d lib/src/rust -c rust/src/frb_generated.c --rust-root rust

# Flutter clean
flutter-clean:
	flutter clean

# Cargo clean
cargo-clean:
	cargo clean --manifest-path rust/Cargo.toml

# Cargo build
cargo-build:
	cargo build --manifest-path rust/Cargo.toml

# Cargo build release
cargo-build-release:
	cargo build --release --manifest-path rust/Cargo.toml

# Cargo run (if you have a binary, e.g. for backend)
cargo-run:
	cargo run --manifest-path rust/Cargo.toml

# Flutter pub get
flutter-pub-get:
	flutter pub get

# Flutter build
flutter-build:
	flutter build

# Complete rebuild (clean everything and regenerate)
rebuild: flutter-clean cargo-clean flutter-pub-get frb-gen cargo-build

# Quick development cycle (generate code and build)
dev: frb-gen cargo-build flutter-pub-get

# Help
help:
	@echo "Available commands:"
	@echo "  frb-gen           - Generate Flutter Rust Bridge code"
	@echo "  flutter-clean     - Clean Flutter build cache"
	@echo "  cargo-clean       - Clean Rust build cache"
	@echo "  cargo-build       - Build Rust project"
	@echo "  cargo-build-release - Build Rust project in release mode"
	@echo "  cargo-run         - Run Rust binary (if exists)"
	@echo "  flutter-pub-get   - Get Flutter dependencies"
	@echo "  flutter-build     - Build Flutter project"
	@echo "  rebuild           - Complete rebuild (clean + regenerate + build)"
	@echo "  dev               - Quick dev cycle (generate + build)"
	@echo "  help              - Show this help message" 