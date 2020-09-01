FROM ubuntu:16.04 AS BUILD

COPY scripts /scripts
RUN  bash /scripts/build-linux.sh


FROM alpine:latest
COPY --from=BUILD /graphql-engine /graphql-engine

