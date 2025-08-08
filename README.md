# llama.cpp

Custom build of llama.cpp in container.

## Build and run

    # Get model
    mkdir models && cd models && curl -O -L https://huggingface.co/unsloth/gpt-oss-20b-GGUF/resolve/main/gpt-oss-20b-F16.gguf

    podman build -t localhost/jdobes/llama.cpp:latest .
    podman run --rm -v ./models:/models:Z -p 8080:8080 localhost/jdobes/llama.cpp:latest \
        llama-server -m /models/gpt-oss-20b-F16.gguf \
                     --no-webui \                     
                     --jinja \
                     --ctx-size 16384 \
                     --temp 1.0 \
                     --top-p 1.0 \
                     --top-k 0
