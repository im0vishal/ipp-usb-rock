## THE ROCK (OCI CONTAINER IMAGE)

## The ipp-usb Rock

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

Create a Docker volume:
```sh
  sudo docker volume create ipp-usb-data
```

To run the container after pulling the image, use:
```sh
  sudo docker run -d --network host \
      -v /dev/bus/usb:/dev/bus/usb:ro \
      -v ipp-usb-data:/var/lib/ipp-usb \
      --device-cgroup-rule='c 189:* rmw' \
      --name ipp-usb \
      ghcr.io/openprinting/ipp-usb:latest
```
- `--network host`: Uses the host’s network for IPP-over-USB and Avahi service discovery, enabling seamless printer detection.
- `-v /dev/bus/usb:/dev/bus/usb:ro`: Grants read-only access to USB devices, allowing the container to detect USB printers.
- `-v ipp-usb-data:/var/lib/ipp-usb`: Provides persistent storage for IPP-USB data, ensuring configuration and logs remain after restarts.
- `--device-cgroup-rule='c 189:* rmw'`: Allows read, write, and device management for USB printers inside the container.

To check the logs of `ipp-usb`, run:
```sh
  sudo docker logs -f ipp-usb
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

Create a Docker volume:
```sh
  sudo docker volume create ipp-usb-data
```

**Run the `ipp-usb` Docker Container**

```sh
  sudo docker run -d --network host \
      -v /dev/bus/usb:/dev/bus/usb:ro \
      -v ipp-usb-data:/var/lib/ipp-usb \
      --device-cgroup-rule='c 189:* rmw' \
      --name ipp-usb \
      ipp-usb:latest
```
- `--network host`: Uses the host’s network for IPP-over-USB and Avahi service discovery, enabling seamless printer detection.
- `-v /dev/bus/usb:/dev/bus/usb:ro`: Grants read-only access to USB devices, allowing the container to detect USB printers.
- `-v ipp-usb-data:/var/lib/ipp-usb`: Provides persistent storage for IPP-USB data, ensuring configuration and logs remain after restarts.
- `--device-cgroup-rule='c 189:* rmw'`: Allows read, write, and device management for USB printers inside the container.

### Accessing the Container Shell

To enter the running `ipp-usb` container and access a shell inside it, use:
```sh
  sudo docker exec -it ipp-usb bash
```
This allows you to inspect logs, debug issues, or manually run commands inside the container.


