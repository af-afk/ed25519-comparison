
ed25519-comparison.wasm: $(shell find Cargo.* src -type f)
	@rm -f ed25519_comparison.wasm
	@cargo build --release --target wasm32-unknown-unknown
	@./wasm-post.sh \
		target/wasm32-unknown-unknown/release/ed25519_comparison.wasm \
		ed25519_comparison.wasm
	@./check-codesize.sh ed25519-comparison.wasm
