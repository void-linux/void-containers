# Void Linux Docker Images

This repo contains the dockerfiles needed to build void-linux docker
images.  There are 5 images provided:

  * `full`: Large image based on the base-minimal package and does not
    contain a noextract configuration.  If you want something that is
    as close to a full void VM as possible, this is the image you want
    to start with.  These images average 242MB

  * `thin`: This image contains far fewer packages and uses a
    noextract file to prevent certain directories from being added to
    the image.  These images average 40MB.

  * `thin-bb`: This image is the same as the thin image above, but
    uses busybox instead of GNU coreutils.  Note that this is not a
    well tested configuration with Void, but if you want minimalism
    without breaking xbps-pkgdb, busybox is a good way to get it given
    that these images average 34.4MB.

  * `mini`: The mini image is the same as the thin image in terms of
    configuration, but all binaries and libraries a stripped.  This
    brings the image size down to an average of 20MB, but the tradeoff
    is that xbps-pkdb will complain that the files no longer match
    their checksums.

  * `mini-bb`: Same as thin-bb but stripped.  Average size is 15MB.


Each image can also be built using the musl C library by passing an
appropriate `XBPS_ARCH` value during the build.  For comparison, here
is the size of all images built for both architectures on x86_64.

```
REPOSITORY                            TAG                                                    SIZE
ghcr.io/void-linux/void-linux         20210220rc01-full-x86_64-musl                          92.78MB
ghcr.io/void-linux/void-linux         20210220rc01-full-x86_64                               152.6MB
ghcr.io/void-linux/void-linux         20210220rc01-mini-bb-x86_64                            14.48MB
ghcr.io/void-linux/void-linux         20210220rc01-mini-x86_64                               20.84MB
ghcr.io/void-linux/void-linux         20210220rc01-mini-bb-x86_64-musl                       8.624MB
ghcr.io/void-linux/void-linux         20210220rc01-thin-bb-x86_64                            34.38MB
ghcr.io/void-linux/void-linux         20210220rc01-thin-bb-x86_64-musl                       12.17MB
ghcr.io/void-linux/void-linux         20210220rc01-thin-x86_64-musl                          19.1MB
ghcr.io/void-linux/void-linux         20210220rc01-mini-x86_64-musl                          15.55MB
ghcr.io/void-linux/void-linux         20210220rc01-thin-x86_64                               40.74MB
```
