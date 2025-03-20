## THE ROCK (OCI CONTAINER IMAGE)

## The ipp-usb Rock

### Install from GitHub Container Registry
#### Prerequisites

1. **Docker Installed**: Ensure Docker is installed on your system. You can download it from the [official Docker website](https://www.docker.com/get-started).
```sh
  sudo snap install docker
```

### **Running the `ipp-usb` Container with Persistent Storage**  

To run the `ipp-usb` container while ensuring that its state persists across restarts, follow these steps.  

#### **1. Pull the `ipp-usb` Docker Image**  
The latest image is available on the GitHub Container Registry. Pull it using:  
```sh
  sudo docker pull ghcr.io/openprinting/ipp-usb:latest
```  

#### **2. Create a Persistent Storage Volume**  
`ipp-usb` maintains important state files that should persist across container restarts. Create a Docker volume for this:  
```sh
  sudo docker volume create ipp-usb-storage
```  
This volume will store:  
- **Persistent state files** (`/var/ipp-usb/dev/`) – Ensures stable TCP port allocation and DNS-SD name resolution.  
- **Lock files** (`/var/ipp-usb/lock/`) – Prevents multiple instances from running simultaneously.  


#### **3. Run the Container with Required Mounts**  
Start the container with the necessary options:  
```sh
sudo docker run -d --network host \
    -v /dev/bus/usb:/dev/bus/usb:ro \
    -v ipp-usb-storage:/var/ipp-usb \
    --device-cgroup-rule='c 189:* rmw' \
    --name ipp-usb \
    ghcr.io/openprinting/ipp-usb:latest
```  
 
- **`--network host`** → Uses the host’s network for proper IPP-over-USB and Avahi service discovery.  
- **`-v /dev/bus/usb:/dev/bus/usb:ro`** → Grants read-only access to USB devices, allowing printer detection.  
- **`-v ipp-usb-storage:/var/ipp-usb`** → Mounts the persistent storage volume, ensuring printer state persists across reboots.  
- **`--device-cgroup-rule='c 189:* rmw'`** → Grants read, write, and management permissions for USB printers inside the container.  

### Building and Running `ipp-usb` Locally

#### Prerequisites

1. **Docker Installed**: Ensure Docker is installed on your system. You can download it from the [official Docker website](https://www.docker.com/get-started) or from the Snap Store:
```sh
  sudo snap install docker
```

2. **Rockcraft**: Rockcraft should be installed. You can install Rockcraft using the following command:
```sh
  sudo snap install rockcraft --classic
```

**To Build and Run the `ipp-usb` Rock Image Locally, follow these steps** 

**1. Build the `ipp-usb` Rock Image**  
The first step is to build the Rock image from the `rockcraft.yaml` configuration file. This image will include all required dependencies and configurations for `ipp-usb`.  

Navigate to the directory containing `rockcraft.yaml` and run:  
```sh
  rockcraft pack -v
```  

**2. Convert the Rock Image to a Docker Image**  
Once the `.rock` file is built, convert it into a Docker image using:  
```sh
sudo rockcraft.skopeo --insecure-policy copy oci-archive:<rock_image> docker-daemon:ipp-usb:latest
```  

**3. Create a Persistent Storage Volume**  
To maintain state across restarts, create a Docker volume for `ipp-usb`:  
```sh
sudo docker volume create ipp-usb-storage
```  
This volume stores:  
- **Persistent state files** (`/var/ipp-usb/dev/`) – Ensures stable TCP port allocation and DNS-SD name resolution.  
- **Lock files** (`/var/ipp-usb/lock/`) – Prevents multiple instances from running simultaneously.  

**4. Run the Container with Required Mounts**  
Start the `ipp-usb` container locally using:  
```sh
sudo docker run -d --network host \
    -v /dev/bus/usb:/dev/bus/usb:ro \
    -v ipp-usb-storage:/var/ipp-usb \
    --device-cgroup-rule='c 189:* rmw' \
    --name ipp-usb \
    ipp-usb:latest
```  
 
- **`--network host`** → Uses the host’s network for proper IPP-over-USB and Avahi service discovery.  
- **`-v /dev/bus/usb:/dev/bus/usb:ro`** → Grants read-only access to USB devices, allowing printer detection.  
- **`-v ipp-usb-storage:/var/ipp-usb`** → Mounts the persistent storage volume, ensuring printer state persists across reboots.  
- **`--device-cgroup-rule='c 189:* rmw'`** → Grants read, write, and management permissions for USB printers inside the container.  

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
By default, the container uses the built-in configuration, which can be modified from inside the container. 

### **Modifying the Configuration File Inside the Container**  

#### **1 Enter the Running Container**  
Use the following command to access the container’s shell:  
```sh
sudo docker exec -it ipp-usb bash
```

#### **2 Open the Configuration File in Nano**  
Once inside the container, open the configuration file using `nano`:  
```sh
nano /etc/ipp-usb/ipp-usb.conf
```

#### **3 Edit and Save the File**  
- Make the necessary changes to the file.  
- Press `CTRL + X`, then `Y`, and hit `Enter` to save the changes.  

#### **4 Restart the Container to Apply Changes**  
Exit the container and restart it to apply the updated configuration:  
```sh
sudo docker restart ipp-usb
```

### **Viewing Logs in the `ipp-usb` Container**  

The `ipp-usb` container logs important events and errors to `/var/log/ipp-usb/main.log`. Since the container is immutable, logs are stored inside the container and can be accessed using Docker commands.  

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
tail -f /var/log/ipp-usb/main.log
```  
This will display new log entries in real-time. If you only want to see the last few lines, use:  
```sh
tail -n 50 /var/log/ipp-usb/main.log
```  
To view the full log file at once, use:  
```sh
cat /var/log/ipp-usb/main.log
```  

Using `tail -f` is preferable for continuous monitoring, whereas `cat` is better for quick one-time checks.



