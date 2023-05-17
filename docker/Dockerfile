# Source: https://github.com/foundry-rs/foundry/blob/master/Dockerfile
# Source: https://github.com/paritytech/scripts/blob/master/dockerfiles/base-ci-linux/Dockerfile
# Source: https://github.com/paritytech/scripts/blob/master/dockerfiles/contracts-ci-linux/Dockerfile
# Changes shown in Git commits whereever possible

FROM docker.io/library/debian:bullseye-slim
ARG DEBIAN_CODENAME=bullseye
# don't need Rust if using pre-build binaries from Foundry instead of building from source
# ARG RUST_NIGHTLY="2023-03-21"

ENV HOME="/root"
ENV SHELL /bin/bash
ENV DEBIAN_FRONTEND=noninteractive
# show backtraces
# don't need Rust if using pre-build binaries from Foundry instead of building from source
# ENV	RUST_BACKTRACE=1

# don't need if not using NVM and v18.x
# ENV NVM_DIR="${HOME}/.nvm"
# ENV NVM_VERSION=v0.39.3
# ENV NODE_VERSION="v20.1.0"

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
        CXX=clang-14

# don't need Rust if using pre-build binaries from Foundry instead of building from source
RUN export TARGETARCH=arm64 && echo "export CFLAGS=-mno-outline-atomics" >> $HOME/.profile || true

WORKDIR /opt

# install tools and dependencies
# RUN set -eux; \
# https://docs.docker.com/build/cache/
# RUN --mount=type=cache,target="${HOME}/.cargo/registry" \
#     --mount=type=cache,target="${HOME}/.cargo/git" \
#     # --mount=type=cache,target=/opt/foundry/target \
RUN apt-get -y update; \
    # apt-get -y upgrade; \
    apt-get install -y --no-install-recommends \
        libssl-dev make cmake graphviz \
        git pkg-config curl time rhash ca-certificates jq \
        python3 python3-pip lsof ruby ruby-bundler git-restore-mtime xz-utils zstd unzip gnupg protobuf-compiler && \
    apt-get install -y vim wget net-tools iptables iproute2 iputils-ping && \
    # don't need Rust if using pre-build binaries from Foundry instead of building from source
    # add clang 14 repo
    echo "deb http://apt.llvm.org/${DEBIAN_CODENAME}/ llvm-toolchain-${DEBIAN_CODENAME}-14 main" >> /etc/apt/sources.list.d/llvm-toolchain-${DEBIAN_CODENAME}-14.list; \
    echo "deb-src http://apt.llvm.org/${DEBIAN_CODENAME}/ llvm-toolchain-${DEBIAN_CODENAME}-14 main" >> /etc/apt/sources.list.d/llvm-toolchain-${DEBIAN_CODENAME}-14.list; \
    #
    # don't need Rust if using pre-build binaries from Foundry instead of building from source
    apt-get -y update; \
    apt-get install -y --no-install-recommends \
        clang-14 lldb-14 lld-14 libclang-14-dev && \
    # install specific minio client version (2023-04-06)
    curl -L "https://dl.min.io/client/mc/release/linux-amd64/archive/mc.RELEASE.2023-04-06T16-51-10Z" -o /usr/local/bin/mc && \
    chmod 755 /usr/local/bin/mc && \
    # set a link to clang
    update-alternatives --install /usr/bin/cc cc /usr/bin/clang-14 100; \
    # set a link to ldd
    update-alternatives --install /usr/bin/ld ld /usr/bin/ld.lld-14 100; \
    #
    # # install rustup, use minimum components
    # curl -L "https://static.rust-lang.org/rustup/dist/x86_64-unknown-linux-gnu/rustup-init" \
    #     -o rustup-init; \
    # chmod +x rustup-init; \
    # ./rustup-init -y --no-modify-path --profile minimal --default-toolchain stable; \
    #
    # RUN apk add clang lld curl build-base linux-headers git && \
    #
    # don't need Rust if using pre-build binaries from Foundry instead of building from source
    # curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > rustup.sh && \
    # chmod +x ./rustup.sh && \
    # ./rustup.sh -y && \
    # pip install yq; \
    # cargo install sccache; \
    # rustup show; \
    # cargo --version; \
    #
    # #
    # echo "CARGO HERE" && \
    # ls -al "${HOME}/.cargo/" && \
    # #
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
    # install foundry https://getfoundry.sh/
    # https://github.com/foundry-rs/foundry
    # https://book.getfoundry.sh/
    # MUD v1 (legacy)
    # https://mud.dev/guides/getting_started/
    # https://github.com/latticexyz/mud
    # mkdir -p "${HOME}/.cargo/registry" && \
    # mkdir -p "${HOME}/.cargo/git" && \
    # https://book.getfoundry.sh/getting-started/installation
    # Forge, Cast, Anvil
    # https://book.getfoundry.sh/anvil/
    # https://book.getfoundry.sh/reference/anvil/
    #
    # install Foundry pre-compiled binaries (fast)
    curl -L https://foundry.paradigm.xyz | bash && \
    # update to latest binaries foundryup, anvil, cast, chisel, forge 
    ${HOME}/.foundry/bin/foundryup && \
    \. "${HOME}/.bashrc" && \
    cat "${HOME}/.bashrc" && \
    #
    # # build from source (not necessary and takes a long time)
    # # clone the repository
    # git clone https://github.com/foundry-rs/foundry.git && \
    # cd foundry && \
    # # install Forge + Cast
    # cargo install --path ./cli --profile local --bins --force && \
    # # install Anvil
    # cargo install --path ./anvil --profile local --force && \
    # # install Chisel
    # cargo install --path ./chisel --profile local --force && \
    # # mkdir -p /opt/foundry && \
    # # cd /opt/foundry && \
    # \. "${HOME}/.profile" && cargo build --release && \
    # mkdir out && \
    # cp target/release/forge out/forge && \
    # cp target/release/cast out/cast && \
    # cp target/release/anvil out/anvil && \
    # strip out/forge && \
    # strip out/cast && \
    # strip out/anvil && \
    # cp /opt/foundry/out/forge /usr/local/bin/forge && \
    # cp /opt/foundry/out/cast /usr/local/bin/cast && \
    # cp /opt/foundry/out/anvil /usr/local/bin/anvil && \
    #
    # MUD v2
    # https://v2.mud.dev/contribute
    # MUD v2 uses Foundry for testing and building
    # install Go
    wget https://dl.google.com/go/go1.20.4.linux-amd64.tar.gz && \
    # -C to move to given directory
    tar -C /usr/local/ -xzf go1.20.4.linux-amd64.tar.gz && \
    echo 'export PATH="$PATH:/usr/local/go/bin"' >> "${HOME}/.profile" && \
    # install PNPM
    npm install pnpm --global && \
    # we don't need to build mud from source like below
    # install MUD
    # git clone https://github.com/latticexyz/mud && \
    # cd mud && pnpm install && \
    # install GRPCurl to interact with Store (embedded EVM database) for MUD
    # https://v2.mud.dev/what-is-mud
    # https://v2.mud.dev/mode
    # https://v2.mud.dev/store
    curl -sSL "https://github.com/fullstorydev/grpcurl/releases/download/v1.8.7/grpcurl_1.8.7_linux_x86_64.tar.gz" | tar -xz -C /usr/local/bin

EXPOSE 3000 8545

CMD tail -f /dev/null
# ENTRYPOINT ["/bin/sh", "-c"]


# # `binaryen` is needed by `cargo-contract` for optimizing Wasm files.
# # We fetch the latest release which contains a Linux binary.
# curl -L $(curl --silent https://api.github.com/repos/WebAssembly/binaryen/releases \
# 	 | jq -r '.[0].assets | [.[] | .browser_download_url] | map(select(match("x86_64-linux\\.tar\\.gz$"))) | .[0]' \
# 	 ) | tar -xz -C /usr/local/bin/ --wildcards --strip-components=2 'binaryen-*/bin/wasm-opt' && \

# # The stable toolchain is used to build ink! contracts through the use of the
# # `RUSTC_BOOSTRAP=1` environment variable. We also need to install the
# # `wasm32-unknown-unknown` target
# rustup target add wasm32-unknown-unknown --toolchain stable && \
# rustup component add rust-src --toolchain stable && \
# rustup default stable && \
# # nightly toolchain for linting. perform checks using RustFmt, and Cargo Clippy.
# rustup toolchain install nightly-${RUST_NIGHTLY} --target wasm32-unknown-unknown \
# 	--profile minimal --component rustfmt clippy rust-src && \

# # Alias pinned toolchain as nightly, otherwise it appears as though we
# # don't have a nightly toolchain (i.e rustc +nightly --version is empty)
# ln -s "/usr/local/rustup/toolchains/nightly-${RUST_NIGHTLY}-x86_64-unknown-linux-gnu" \
# 	/usr/local/rustup/toolchains/nightly-x86_64-unknown-linux-gnu && \

