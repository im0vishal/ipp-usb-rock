#### ipp-usb-rock

## THE ROCK (OCI CONTAINER IMAGE)

### Install from GitHub Container Registry
#### Prerequisites

1. **Docker Installed**: Ensure Docker is installed on your system. You can download it from the [official Docker website](https://www.docker.com/get-started).
```sh
  sudo snap install docker
```

#### Step-by-Step Guide

You can pull the `ipp-usb` Docker image from the GitHub Container Registry.

**From GitHub Container Registry** <br>
To pull the image from the GitHub Container Registry, run the following command:
```sh
  sudo docker pull ghcr.io/openprinting/ipp-usb:latest
```

To run the container after pulling the image, use:
```sh
  sudo docker run --rm --network host \
      -v /dev/bus/usb:/dev/bus/usb:ro \
      --device-cgroup-rule='c 189:* rmw' \
      --name ipp-usb-container \
      ghcr.io/openprinting/ipp-usb:latest
```

- `--rm`: Automatically removes the container once it stops.
- `--network host`: Ensures IPP-over-USB communication and Avahi service discovery work correctly.
- `-v /dev/bus/usb:/dev/bus/usb:ro`: Grants the container read-only access to USB devices.
- `--device-cgroup-rule='c 189:* rmw'`: Allows the container to manage USB devices.

To check the logs of `ipp-usb`, run:
```sh
  sudo docker logs -f ipp-usb-container
```

### Building and Running `ipp-usb` Locally

#### Prerequisites

**Docker Installed**: Ensure Docker is installed on your system. You can download it from the [official Docker website](https://www.docker.com/get-started) or from the Snap Store:
```sh
  sudo snap install docker
```

**Rockcraft**: Rockcraft should be installed. You can install Rockcraft using the following command:
```sh
  sudo snap install rockcraft --classic
```

**Skopeo**: Skopeo should be installed to compile `*.rock` files into Docker images. It comes bundled with Rockcraft, so no separate installation is required.

#### Step-by-Step Guide

**Build the `ipp-usb` Rock Image**

The first step is to build the Rock from the `rockcraft.yaml`. This image will contain all the configurations and dependencies required to run `ipp-usb`.

Navigate to the directory containing `rockcraft.yaml`, then run:
```sh
  rockcraft pack -v
```

**Compile to Docker Image**

Once the `.rock` file is built, compile a Docker image from it using:
```sh
  sudo rockcraft.skopeo --insecure-policy copy oci-archive:<rock_image> docker-daemon:ipp-usb:latest
```

**Run the `ipp-usb` Docker Container**

```sh
  sudo docker run --rm --network host \
      -v /dev/bus/usb:/dev/bus/usb:ro \
      --device-cgroup-rule='c 189:* rmw' \
      --name <ipp-usb-container-name> \
      ipp-usb:latest
```

### Configuration

The `ipp-usb` container uses a configuration file located at:
```
/etc/ipp-usb.conf
```
To customize the configuration, mount a modified config file:
```sh
  sudo docker run --rm --network host \
      -v /dev/bus/usb:/dev/bus/usb:ro \
      --device-cgroup-rule='c 189:* rmw' \
      -v /path/to/custom/ipp-usb.conf:/etc/ipp-usb.conf:ro \
      --name <ipp-usb-container-name> \
      ghcr.io/openprinting/ipp-usb:latest
```

### Handling UDEV Events

Since `ipp-usb` relies on `UDEV` rules to detect IPP-over-USB devices, and containerized environments do not allow direct modification of system-wide `UDEV` rules, the Rock image includes a workaround. It monitors `UDEV` events using `udevadm` inside the container to detect device connections dynamically.
```
