ARG VARIANT

FROM ghcr.io/chipp/build.musl.${VARIANT}:musl_1.2.5_1

COPY ./build.sh ./build.sh
RUN chmod +x ./build.sh && \
  ./build.sh && \
  rm ./build.sh

