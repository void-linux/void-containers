# syntax=docker/dockerfile:1
FROM --platform=${BUILDPLATFORM} alpine:3.22 AS bootstrap
ARG TARGETPLATFORM
ARG MIRROR=https://repo-ci.voidlinux.org
ARG LIBC
RUN apk add ca-certificates curl && \
  curl "${MIRROR}/static/xbps-static-static-0.59_5.$(uname -m)-musl.tar.xz" | tar vJx
COPY keys/* /target/var/db/xbps/keys/
COPY setup.sh /bootstrap/setup.sh
COPY noextract-python.conf /target/etc/xbps.d/noextract-python.conf
RUN --mount=type=cache,sharing=locked,target=/target/var/cache/xbps,id=repocache-${LIBC} \
  . /bootstrap/setup.sh; \
  XBPS_TARGET_ARCH=${ARCH} xbps-install -S \
    -R "${REPO}" \
    -r /target

FROM --platform=${BUILDPLATFORM} bootstrap AS install-default
ARG TARGETPLATFORM
ARG MIRROR
ARG LIBC
COPY --from=bootstrap /target /target
COPY noextract.conf /target/etc/xbps.d/noextract.conf
RUN --mount=type=cache,sharing=locked,target=/target/var/cache/xbps,id=repocache-${LIBC} \
  . /bootstrap/setup.sh; \
  XBPS_TARGET_ARCH=${ARCH} xbps-install -y \
    -R "${REPO}" \
    -r /target \
    xbps base-files dash coreutils grep run-parts sed gawk

FROM --platform=${BUILDPLATFORM} bootstrap AS install-busybox
ARG TARGETPLATFORM
ARG MIRROR
ARG LIBC
COPY --from=bootstrap /target /target
COPY noextract.conf /target/etc/xbps.d/noextract.conf
RUN --mount=type=cache,sharing=locked,target=/target/var/cache/xbps,id=repocache-${LIBC} \
  . /bootstrap/setup.sh; \
  XBPS_TARGET_ARCH=${ARCH} xbps-install -y \
    -R "${REPO}" \
    -r /target \
    xbps base-files busybox-huge

FROM --platform=${BUILDPLATFORM} bootstrap AS install-full
ARG TARGETPLATFORM
ARG MIRROR
ARG LIBC
COPY --from=bootstrap /target /target
RUN --mount=type=cache,sharing=locked,target=/target/var/cache/xbps,id=repocache-${LIBC} \
  . /bootstrap/setup.sh; \
  XBPS_TARGET_ARCH=${ARCH} xbps-install -y \
    -R "${REPO}" \
    -r /target \
    base-container

FROM scratch AS image-default
COPY --link --from=install-default /target /
RUN \
  install -dm1777 tmp; \
  xbps-reconfigure -fa; \
  rm -rf /var/cache/xbps/*
CMD ["/bin/sh"]

FROM scratch AS image-busybox
COPY --link --from=install-busybox /target /
RUN \
  for util in $(/usr/bin/busybox --list); do \
    [ ! -f "/usr/bin/$util" ] && /usr/bin/busybox ln -sfv busybox "/usr/bin/$util"; \
  done; \
  install -dm1777 tmp; \
  xbps-reconfigure -fa; \
  rm -rf /var/cache/xbps/*
CMD ["/bin/sh"]

FROM scratch AS image-full
COPY --link --from=install-full /target /
RUN \
  install -dm1777 tmp; \
  xbps-reconfigure -fa; \
  rm -rf /var/cache/xbps/*
CMD ["/bin/sh"]
