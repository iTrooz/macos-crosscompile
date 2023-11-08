DELETE_SDK ?= 1

default:
	echo "No default target"

.PHONY: crosscompile_img
crosscompile_img:
	docker buildx build crosscompile --progress plain -t crosscompile --build-arg "JOBS=$(JOBS)" --build-arg "DELETE_SDK=$(DELETE_SDK)"

.PHONY: imhex_img
imhex_img:
	docker buildx build . -f imhex/Dockerfile --progress plain --build-arg 'JOBS=$(JOBS)' --build-arg 'BUILD_TYPE=$(BUILD_TYPE)' --build-arg 'CUSTOM_GLFW=$(CUSTOM_GLFW)' --build-context imhex=${IMHEX_DIR} --target=build -t imhex

.PHONY: imhex_bin
imhex_bin:
	docker buildx build . -f imhex/Dockerfile --progress plain --build-arg 'JOBS=$(JOBS)' --build-arg 'BUILD_TYPE=$(BUILD_TYPE)' --build-arg 'CUSTOM_GLFW=$(CUSTOM_GLFW)' --build-context imhex=${IMHEX_DIR} --output .

.PHONY: clean
clean:
	rm imhex.dmg
