FROM golang:1.25 AS op

WORKDIR /app

ENV CGO_ENABLED=0
ENV OP_REPO=https://github.com/ethereum-optimism/optimism.git
ENV OP_VERSION=${OP_VERSION:-v1.14.1}

RUN git clone $OP_REPO --depth 1 --branch op-node/$OP_VERSION --single-branch ./optimism && \
    cd optimism && git switch -c branch-$OP_VERSION && \
    git submodule sync --recursive && git submodule update --init --recursive && \
    go build -o /app/op-node ./op-node/cmd && \
    go build -o /app/op-batcher ./op-batcher/cmd && \
    go build -o /app/op-proposer ./op-proposer/cmd && \
    go build -o /app/op-challenger ./op-challenger/cmd && \
    go build -o /app/cannon ./cannon && \
    go build -o /app/op-program ./op-program

FROM golang:1.25 AS geth

WORKDIR /app

ENV GETH_REPO=https://github.com/ethereum-optimism/op-geth.git
ENV GETH_VERSION=${GETH_VERSION:-v1.101603.1}

RUN git clone $GETH_REPO --depth 1 --branch $GETH_VERSION --single-branch . && \
    git switch -c branch-$GETH_VERSION && \
    make geth

FROM debian:stable

COPY *-entrypoint.sh /script/
RUN chmod +x /script/*.sh

WORKDIR /app

RUN apt-get update && \
    apt-get install -y sudo jq curl wget lz4 && \
    rm -rf /var/lib/apt/lists

COPY --from=op /app/op-node ./
COPY --from=op /app/op-batcher ./
COPY --from=op /app/op-proposer ./
COPY --from=op /app/op-challenger ./
COPY --from=op /app/cannon ./
COPY --from=op /app/op-program ./
COPY --from=geth /app/build/bin/geth ./