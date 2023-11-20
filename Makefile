build:
	docker buildx build \
		--platform=linux/amd64,linux/arm64 --push \
		--provenance=false \
		--build-arg UID=1012 \
		--build-arg GID=1012 \
		-t aesirxio/website-evidence-collector:latest .

build-dev:
	docker buildx build \
		--platform=linux/amd64,linux/arm64 --push \
		--provenance=false \
		--build-arg UID=1010 \
		--build-arg GID=1010 \
		-t aesirxio/website-evidence-collector:dev .