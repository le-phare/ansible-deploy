build:
	docker buildx bake

build-all:
	docker run --privileged --rm tonistiigi/binfmt --install all
	docker buildx bake image-all
