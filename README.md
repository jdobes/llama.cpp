# llama.cpp

Custom build of llama.cpp in container. Built for Linux `amd64` and `arm64`. CPU-only support at the moment.

## Get the image

    podman pull ghcr.io/jdobes/llama.cpp:latest

## Or build locally

    podman build -t ghcr.io/jdobes/llama.cpp:latest --build-arg RELEASE=b6117 .

## Run it

    # Get model
    mkdir models && cd models && curl -O -L https://huggingface.co/unsloth/gpt-oss-20b-GGUF/resolve/main/gpt-oss-20b-F16.gguf

    podman run --rm -v ./models:/models:Z -p 8080:8080 ghcr.io/jdobes/llama.cpp:latest \
        llama-server -m /models/gpt-oss-20b-F16.gguf \                    
                     --jinja \
                     --ctx-size 16384 \
                     --temp 1.0 \
                     --top-p 1.0 \
                     --top-k 0
