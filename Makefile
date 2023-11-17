multi-arch-docker-build:
	docker buildx build \
		--platform=linux/amd64,linux/arm64 --push \
		--provenance=false \
		-t aesirxio/website-evidence-collector:latest .
	