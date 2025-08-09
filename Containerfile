FROM registry.access.redhat.com/ubi10/ubi AS buildimg

ARG RELEASE=b6117

WORKDIR /work

RUN dnf install -y cmake gcc-c++ libcurl-devel openblas-devel

RUN curl -O -L https://github.com/ggml-org/llama.cpp/archive/refs/tags/${RELEASE}.tar.gz && \
    tar -xf ${RELEASE}.tar.gz && \
    rm -f ${RELEASE}.tar.gz && \
    cd llama.cpp-${RELEASE} && \
    if [ "$(uname -m)" == "aarch64" ]; then EXTRA_ARGS="-DGGML_CPU_ARM_ARCH=armv8-a"; else EXTRA_ARGS=""; fi && \
    cmake -B build -DCMAKE_BUILD_TYPE=Release -DGGML_NATIVE=OFF -DLLAMA_BUILD_TESTS=OFF -DGGML_BLAS=ON -DGGML_BLAS_VENDOR=OpenBLAS $EXTRA_ARGS && \
    cmake --build build --config Release -j $(nproc) --target llama-cli llama-server llama-bench

# Copy required system libs to have them on one place
RUN cd llama.cpp-${RELEASE} && \
    ldd build/bin/llama-cli build/bin/llama-server build/bin/llama-bench \ 
    | awk '/=>/ {print $3}' \
    | sort -u \
    | grep '/lib64' \
    | while read lib ; do \
        cp $lib build/bin/ ; \
      done

# =======================================================
FROM registry.access.redhat.com/ubi10/ubi-micro AS runimg

ARG RELEASE=b6117

COPY --from=buildimg /work/llama.cpp-${RELEASE}/build/bin/*.so* /usr/lib64/
COPY --from=buildimg /work/llama.cpp-${RELEASE}/build/bin/llama-cli \
                     /work/llama.cpp-${RELEASE}/build/bin/llama-server \
                     /work/llama.cpp-${RELEASE}/build/bin/llama-bench \
                     /usr/bin/

ENV LLAMA_ARG_HOST=0.0.0.0
