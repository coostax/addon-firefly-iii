# Local docker build

To build the image locally run the following:

´´´
docker build \
--build-arg BUILD_FROM="ghcr.io/hassio-addons/debian-base/amd64:7.1.0" \
-t local/addon-firefly-iii .
´´´

To build image on test server:

´´´
docker build \
--build-arg BUILD_FROM="ghcr.io/hassio-addons/debian-base/aarch64:7.1.0" \
-t local/aarch64-addon-firefly-iii:dev .
´´´
