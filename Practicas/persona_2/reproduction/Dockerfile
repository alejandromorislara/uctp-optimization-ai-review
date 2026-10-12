FROM gcc:13.3.0-bookworm

RUN sed -i 's|http://deb.debian.org|https://deb.debian.org|g' /etc/apt/sources.list.d/debian.sources \
    && apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates git libboost-program-options-dev make \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /work/Practicas/persona_2/reproduction

CMD ["bash"]
