all:
	docker buildx build crosscompile --progress plain -t itrooz/crosscompile --build-arg "JOBS=$(JOBS)"
	docker buildx build imhex        --progress plain -t itrooz/imhex        --build-arg 'JOBS=$(JOBS)' --build-arg 'CUSTOM_GLFW=1' --output .        

clean:
	rm imhex.dmg
