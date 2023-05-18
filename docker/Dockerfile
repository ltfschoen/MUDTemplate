# Source: https://github.com/foundry-rs/foundry/blob/master/Dockerfile
# Source: https://github.com/paritytech/scripts/blob/master/dockerfiles/base-ci-linux/Dockerfile
# Source: https://github.com/paritytech/scripts/blob/master/dockerfiles/contracts-ci-linux/Dockerfile
# Changes shown in Git commits whereever possible

FROM docker.io/library/debian:bullseye-slim
ARG DEBIAN_CODENAME=bullseye

ENV HOME="/root"
ENV SHELL /bin/bash
ENV DEBIAN_FRONTEND=noninteractive

ARG TARGETARCH

# don't need Rust if using pre-build binaries from Foundry instead of building from source
# config for wasm32-unknown-unknown & clang
COPY docker/utility/base-ci-linux-config /root/.cargo/config
COPY docker/utility/debian-llvm-clang.key /etc/apt/trusted.gpg.d/debian-llvm-clang.gpg

# don't need Rust if using pre-build binaries from Foundry instead of building from source
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH \
    CC=clang-14 \
    CXX=clang-14 \
    ANVIL_IP_ADDR=0.0.0.0

# don't need Rust if using pre-build binaries from Foundry instead of building from source
RUN export TARGETARCH=arm64 && echo "export CFLAGS=-mno-outline-atomics" >> $HOME/.profile || true

WORKDIR /opt

# install tools and dependencies
# RUN set -eux; \
# https://docs.docker.com/build/cache/
# RUN --mount=type=cache,target="${HOME}/.cargo/registry" \
#     --mount=type=cache,target="${HOME}/.cargo/git" \
#     # --mount=type=cache,target=/opt/foundry/target \
RUN apt-get -y update --fix-missing && \
    apt-get -y upgrade && \
    apt-get install -y --no-install-recommends \
    libssl-dev make cmake graphviz \
    git pkg-config curl time rhash ca-certificates jq \
    python3 python3-pip lsof ruby ruby-bundler git-restore-mtime xz-utils zstd unzip gnupg protobuf-compiler && \
    apt-get install -y vim wget net-tools iptables iproute2 iputils-ping && \
    # don't need Rust if using pre-build binaries from Foundry instead of building from source
    # add clang 14 repo
    echo "deb http://apt.llvm.org/${DEBIAN_CODENAME}/ llvm-toolchain-${DEBIAN_CODENAME}-14 main" >> /etc/apt/sources.list.d/llvm-toolchain-${DEBIAN_CODENAME}-14.list; \
    echo "deb-src http://apt.llvm.org/${DEBIAN_CODENAME}/ llvm-toolchain-${DEBIAN_CODENAME}-14 main" >> /etc/apt/sources.list.d/llvm-toolchain-${DEBIAN_CODENAME}-14.list; \
    apt-get -y update; \
    apt-get install -y --no-install-recommends \
    clang-14 lldb-14 lld-14 libclang-14-dev && \
    # don't need Rust if using pre-build binaries from Foundry instead of building from source
    # don't think minio is necessary
    # install specific minio client version (2023-04-06)
    curl -L "https://dl.min.io/client/mc/release/linux-amd64/archive/mc.RELEASE.2023-04-06T16-51-10Z" -o /usr/local/bin/mc && \
    chmod 755 /usr/local/bin/mc && \
    # set a link to clang
    update-alternatives --install /usr/bin/cc cc /usr/bin/clang-14 100; \
    # set a link to ldd
    update-alternatives --install /usr/bin/ld ld /usr/bin/ld.lld-14 100; \
    apt-get install -y --no-install-recommends zlib1g-dev npm wabt && \
    npm install --ignore-scripts -g yarn && \
    # https://github.com/nodesource/distributions/blob/master/README.md#installation-instructions
    # since MUD v2 requires Node.js v18.x
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    # TODO - consider removing Yarn since we use PNPM for MUD v2
    curl -o- -L https://yarnpkg.com/install.sh | bash && \
    echo 'export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"' >> "${HOME}/.bashrc" && \
    \. "${HOME}/.bashrc" && \
    #
    # install Foundry pre-compiled binaries (fast)
    curl -L https://foundry.paradigm.xyz | bash && \
    # update to latest binaries foundryup, anvil, cast, chisel, forge 
    ${HOME}/.foundry/bin/foundryup && \
    \. "${HOME}/.bashrc" && \
    cat "${HOME}/.bashrc" && \
    #
    # MUD v2 uses Foundry for testing and building
    # install Go
    wget https://dl.google.com/go/go1.20.4.linux-amd64.tar.gz && \
    # -C to move to given directory
    tar -C /usr/local/ -xzf go1.20.4.linux-amd64.tar.gz && \
    echo 'export PATH="$PATH:/usr/local/go/bin"' >> "${HOME}/.profile" && \
    # configure Anvil to avoid CORS issues.
    # not sure if this works, but if it does then it saves having to run with `export ANVIL_IP_ADDR=0.0.0.0 && pnpm run dev`
    # https://github.com/vitejs/vite/discussions/13240
    # https://book.getfoundry.sh/reference/anvil/#usage-within-docker
    echo 'export ANVIL_IP_ADDR=0.0.0.0' >> "${HOME}/.bashrc" && \
    \. "${HOME}/.bashrc" && \
    # install PNPM
    npm install pnpm --global && \
    # install GRPCurl to interact with Store (embedded EVM database) for MUD
    curl -sSL "https://github.com/fullstorydev/grpcurl/releases/download/v1.8.7/grpcurl_1.8.7_linux_x86_64.tar.gz" | tar -xz -C /usr/local/bin

EXPOSE 3000 8545

CMD tail -f /dev/null
# ENTRYPOINT ["/bin/sh", "-c"]
