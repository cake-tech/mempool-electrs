FROM debian:bookworm-slim AS base

ENV CARGO_NET_GIT_FETCH_WITH_CLI=true

RUN DEBIAN_FRONTEND=noninteractive apt update -qy && \
    apt install --no-install-recommends -qy librocksdb-dev curl && \
    apt clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

FROM base as build

RUN DEBIAN_FRONTEND=noninteractive apt update -qy && \
    apt install --no-install-recommends -qy ca-certificates git clang cmake && \
    apt clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV RUSTUP_HOME=/rust
ENV CARGO_HOME=/cargo 
ENV PATH=/cargo/bin:/rust/bin:$PATH

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

WORKDIR /build
COPY . .

RUN cargo build --release --bin electrs

FROM base as deploy

COPY --from=build /build/target/release/electrs /bin/electrs

EXPOSE 50001

ENTRYPOINT ["/bin/electrs"]
