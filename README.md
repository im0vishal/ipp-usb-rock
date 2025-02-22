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
      -v /run/udev:/run/udev:ro \
      --name ipp-usb-container \
      ghcr.io/openprinting/ipp-usb:latest
```

- `--rm`: Automatically removes the container once it stops.
- `--network host`: Uses the host network, ensuring IPP-over-USB and Avahi service discovery work correctly.
- `-v /dev/bus/usb:/dev/bus/usb:ro`: Grants the container read-only access to USB devices.
- `--device-cgroup-rule='c 189:* rmw'`: Grants the container permission to manage USB devices (189:* covers USB device nodes).
- `-v /run/udev:/run/udev:ro`: Mounts udev info, allowing the container to detect new USB devices.

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
  sudo rockcraft.skopeo --insecure-policy copy oci-archive:<rock_image_name> docker-daemon:ipp-usb:latest
```

**Run the `ipp-usb` Docker Container**

```sh
  sudo docker run --rm --network host \
      -v /dev/bus/usb:/dev/bus/usb:ro \
      --device-cgroup-rule='c 189:* rmw' \
      -v /run/udev:/run/udev:ro \
      --name ipp-usb-container \
      ipp-usb:latest
```

### Accessing the Container Shell

To enter the running `ipp-usb` container and access a shell inside it, use:
```sh
  sudo docker exec -it ipp-usb-container bash
```
This allows you to inspect logs, debug issues, or manually run commands inside the container.

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
      -v /run/udev:/run/udev:ro \
      --name ipp-usb-container \
      ghcr.io/openprinting/ipp-usb:latest
```

### Handling UDEV Events

Since `ipp-usb` relies on `UDEV` rules to detect IPP-over-USB devices, and containerized environments do not allow direct modification of system-wide `UDEV` rules, the Rock image includes a workaround. It monitors `UDEV` events using `udevadm` inside the container to detect device connections dynamically.

