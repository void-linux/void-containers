# Void Linux Container Images

This repo contains what is needed to build void-linux OCI container
images. There are 3 images provided for each libc (`glibc` or `musl`):

- `void-LIBC`: This image contains far fewer packages and uses a
  `noextract` file to prevent certain directories from being added to
  the image. These images average 40-65MB.

- `void-LIBC-full`: Large image based on the base-minimal package and
  does not contain a `noextract` configuration. If you want something
  that is as close to a full void VM as possible, this is the image you
  want to start with.These images average 80-135MB.

- `void-LIBC-busybox`: This image is the same as the `void-LIBC` image
  above, but uses busybox instead of GNU coreutils. Note that this is
  not a well tested configuration with Void, but if you want a very
  small image, busybox is a good way to get it. These images average 15-40MB.

These images are available for the following OCI platforms:

- `linux/amd64`
- `linux/386` (`glibc` only)
- `linux/arm64`

> Note: images for `linux/arm/v7` and `linux/arm/v6` are currently unavailable, see issue [#12](https://github.com/void-linux/void-docker/issues/12) for more details

```
REPOSITORY                              TAG      SIZE
ghcr.io/void-linux/void-glibc           latest   64.5MB
ghcr.io/void-linux/void-musl            latest   40.3MB
ghcr.io/void-linux/void-glibc-full      latest   135MB
ghcr.io/void-linux/void-musl-full       latest   81.4MB
ghcr.io/void-linux/void-glibc-busybox   latest   39.6MB
ghcr.io/void-linux/void-musl-busybox    latest   14.4MB
```

## Building locally

With `docker` and  `docker-buildx`:

1. Install and set up `docker` and `docker-buildx`. If building multi-platform images,
  `qemu-user-static`, and `binfmt-support` are also needed:
```sh
xbps-install docker docker-buildx
ln -s /etc/sv/docker /var/service
# optional
xbps-install binfmt-support
ln -s /etc/sv/binfmt-support /var/service
xbps-install qemu-user-static
```
2. Build the image:
```sh
docker build --target "image-<default|full|busybox>" -f Containerfile --build-arg="LIBC=<glibc|musl>" . --tag <yourtag>
```
> Note: To easily build multi-platform images, `docker buildx bake` can be used.

With `podman`:

1. Install and set up `podman`.
2. Build the image:
```sh
podman build --target "image-<default|full|busybox>" --build-arg="LIBC=<glibc|musl>" . --tag <yourtag>
```
