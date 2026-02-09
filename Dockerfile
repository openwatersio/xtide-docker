ARG LIBTCD_VERSION=2.2.7-r3
ARG XTIDE_VERSION=2.16
ARG TCD_UTILS_VERSION=20240222
ARG HARMONICS_VERSION=20251228

# ---------------------------------------------------------------------------
# Builder
# ---------------------------------------------------------------------------
FROM debian:bookworm-slim AS builder

ARG LIBTCD_VERSION
ARG XTIDE_VERSION
ARG TCD_UTILS_VERSION
ARG HARMONICS_VERSION

RUN apt-get update && apt-get install -y --no-install-recommends \
  build-essential libpng-dev zlib1g-dev xz-utils curl ca-certificates \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /src

# libtcd (tarball dir strips release suffix, e.g. 2.2.7-r3 -> libtcd-2.2.7)
RUN curl -fsSL "https://flaterco.com/files/xtide/libtcd-${LIBTCD_VERSION}.tar.xz" | tar xJ \
  && cd libtcd-*/ \
  && ./configure && make && make install

# xtide (CLI + xttpd only, no X11)
RUN curl -fsSL "https://flaterco.com/files/xtide/xtide-${XTIDE_VERSION}.tar.xz" | tar xJ \
  && cd xtide-*/ \
  && CXXFLAGS="-DXTTPD_NO_DAEMON" ./configure --without-x --with-xttpd-group=nogroup \
  && make && make install

# tcd-utils
RUN curl -fsSL "https://flaterco.com/files/xtide/tcd-utils-${TCD_UTILS_VERSION}.tar.xz" | tar xJ \
  && cd tcd-utils-*/ \
  && ./configure && make && make install

# harmonics data (tarball dir omits -free suffix)
RUN mkdir -p /usr/local/share/xtide \
  && curl -fsSL "https://flaterco.com/files/xtide/harmonics-dwf-${HARMONICS_VERSION}-free.tar.xz" | tar xJ \
  && cp harmonics-dwf-*/*.tcd /usr/local/share/xtide/harmonics.tcd

# ---------------------------------------------------------------------------
# Runtime
# ---------------------------------------------------------------------------
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
  libpng16-16 zlib1g \
  && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/ /usr/local/
RUN ldconfig

ENV HFILE_PATH=/usr/local/share/xtide/harmonics.tcd

EXPOSE 8080

CMD ["tide"]
