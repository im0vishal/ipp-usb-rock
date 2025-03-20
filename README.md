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


### Configuration  

The `ipp-usb` container uses a configuration file located at:  
```sh
/etc/ipp-usb/ipp-usb.conf
```
By default, the container uses the built-in configuration, but you can override it by mounting a custom config file.

#### **Mounting a Custom Configuration File**  
To use a modified configuration file, you can mount it from the host system when starting the container:  
```sh
sudo docker run -d --network host \
    -v /dev/bus/usb:/dev/bus/usb:ro \
    -v ipp-usb-data:/var/lib/ipp-usb \
    --device-cgroup-rule='c 189:* rmw' \
    -v /path/to/custom/ipp-usb.conf:/etc/ipp-usb/ipp-usb.conf:ro \
    --name ipp-usb \
    ghcr.io/openprinting/ipp-usb:latest
```
- Replace `/path/to/custom/ipp-usb.conf` with the actual path to your modified config file.  
- The `:ro` flag makes the file **read-only**, ensuring it cannot be modified inside the container.  
- Any changes made to `/path/to/custom/ipp-usb.conf` on the host will apply when the container is restarted.

#### **Editing the Configuration File on the Host**  
Since the Rock image does not include text editors inside the container, you must edit the config file **on the host** before mounting it.  
1. Open the config file with a text editor:  
   ```sh
   nano /path/to/custom/ipp-usb.conf
   ```
2. Modify settings as needed and save the file.  
3. Restart the container to apply changes:  
   ```sh
   sudo docker restart ipp-usb
   ```

   ### **Viewing Logs in the `ipp-usb` Container**  

The `ipp-usb` container logs important events and errors to `/var/log/ipp-usb/main.log`. Since the container is immutable, you need to either **mount the log directory** for persistence or **use Docker commands** to inspect logs.  



#### **1. Using Docker Logs**  
To view real-time logs from the running container, use:  
```sh
sudo docker logs -f ipp-usb
```
- The `-f` flag follows the logs in real-time.  
- Replace `ipp-usb` with your actual container name if different.  



#### **2. Accessing Logs Inside the Container**  
If you need to inspect logs manually, enter the container shell:  
```sh
sudo docker exec -it ipp-usb bash
```
Then, inside the container, run:  
```sh
cat /var/log/ipp-usb/main.log
```



#### **3. Persisting Logs by Mounting a Directory**  
If you want logs to persist after container restarts, mount a host directory to store logs:  
```sh
sudo docker run -d --network host \
    -v /dev/bus/usb:/dev/bus/usb:ro \
    -v ipp-usb-data:/var/lib/ipp-usb \
    -v /path/to/logs:/var/log/ipp-usb \
    --device-cgroup-rule='c 189:* rmw' \
    --name ipp-usb \
    ghcr.io/openprinting/ipp-usb:latest
```
- Replace `/path/to/logs` with an actual directory on your host system.  
- Logs will be available at `/path/to/logs/main.log` on the host.  



#### **4. Checking Logs Without Entering the Container**  
If logs are mounted to a directory on the host, view them directly:  
```sh
cat /path/to/logs/main.log
tail -f /path/to/logs/main.log   # Follow logs in real-time
```


