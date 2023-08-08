default:
	echo "No default target"

.PHONY: crosscompile
crosscompile:
	docker buildx build crosscompile --progress plain -t crosscompile --build-arg "JOBS=$(JOBS)"

.PHONY: imhex
imhex:
	docker buildx build imhex        --progress plain -t imhex        --build-arg 'JOBS=$(JOBS)' --build-arg 'BUILD_TYPE=$(BUILD_TYPE)' --build-arg 'CUSTOM_GLFW=1' --output .        

.PHONY: clean
clean:
	rm imhex.dmg
