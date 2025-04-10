gpustat-web
===========

A web interface of [`gpustat`][gpustat] ---
aggregate `gpustat` across multiple nodes.

<p align="center">
  <img src="https://github.com/wookayin/gpustat-web/raw/master/screenshot.png" width="800" height="192" />
</p>

**NOTE**: This project is in alpha stage. Errors and exceptions are not well handled, and it might use much network resources. Please use at your own risk!


Installation
-----

```
pip install gpustat-web
```

Python 3.6+ is required.

Usage
-----

Launch the application as follows. A SSH connection will be established to each of the specified hosts.
Make sure `ssh <host>` works under a proper authentication scheme such as SSH authentication.

```
gpustat-web --port 48109 HOST1 [... HOSTN]
```

You might get "Host key is not trusted for `<host>`" errors. You'll have to accept and trust SSH keys of the host for the first time (it's stored in `~/.ssh/known_hosts`);
try `ssh <host>` in the command line, or `ssh -oStrictHostKeyChecking=accept-new <host>` to automatically accept the host key. You can also use an option `gpustat-web --no-verify-host` to bypass SSH Host key validation (although not recommended).

Note that asyncssh [does NOT obey](https://github.com/ronf/asyncssh/issues/108) the `~/.ssh/config` file
(e.g. alias, username, keyfile), so any config in `~/.ssh/config` might not be picked up.


[gpustat]: https://github.com/wookayin/gpustat/


### Endpoints

- `https://HOST:PORT/`: A webpage that updates automatically through websocket.
- `https://HOST:PORT/gpustat.html`: Result as a static HTML page.
- `https://HOST:PORT/gpustat.txt`: Result as a static plain text.
- `https://HOST:PORT/gpustat.ansi`: Result as a static text with ANSI color codes. Try `curl https://.../gpustat.ansi`

Query strings:

- `?nodes=gpu001,gpu002`: Select a subset of nodes to query and display


### Running as a HTTP (SSL/TLS) server

By default the web server will run as a HTTP server.
If you want to run a secure SSL/TLS server over the HTTPS protocol, use `--ssl-certfile` and `--ssl-keyfile` option.
You can use letsencrypt (`certbot`) to create a pair of SSL certificate and keyfile.

Troubleshoothing: Verify SSL/TLS handshaking (if TLS connections cannot be established)
```
openssl s_client -showcerts -connect YOUR_HOST.com:PORT < /dev/null
```


### More Examples

To see CPU usage as well:

```
python -m gpustat_web --exec 'gpustat --color --gpuname-width 25 && echo -en "CPU : \033[0;31m" && cpu-usage | ascii-bar 27'
```

# Running the gpustat-web Docker Container

## 1. Prepare SSH Files

### Create known_hosts File (For Host Verification)

Option A: Generate using ssh-keyscan:
```bash
# Create a new known_hosts file with your GPU hosts
ssh-keyscan a.example.com b.example.com > known_hosts_gpustat
```

Option B: Copy from existing known_hosts:
```bash
# If your hosts are already in your known_hosts file
cp ~/.ssh/known_hosts known_hosts_gpustat
```

Ensure your SSH key has correct permissions:
```bash
chmod 600 /path/to/your/id_ed25519
```

## 2. Build the Docker Image

Build the Docker image using the Dockerfile:
```bash
docker build -t gpustat-web .
```

## 3. Run the Docker Container

### Option A: With Host Verification (Recommended)

```bash
docker run -d -p 48109:48109 \
  -v /path/to/your/known_hosts_gpustat:/root/.ssh/known_hosts:ro \
  -v /path/to/your/id_ed25519:/root/.ssh/id_ed25519:ro \
  --name gpustat-web gpustat-web \
  user@a.example.com user@b.example.com
```

### Option B: Without Host Verification

```bash
docker run -d -p 48109:48109 \
  -v /path/to/your/id_ed25519:/root/.ssh/id_ed25519:ro \
  --name gpustat-web gpustat-web \
  --no-verify-host user@a.example.com user@b.example.com
```

## 4. Using Synology Docker UI

1. Open Docker in Synology DSM
2. Go to the "Image" tab and select your "gpustat-web" image
3. Click "Launch" to create a container
4. Configure the container:
   - Set a container name (e.g., "gpustat-web")
   - In "Advanced Settings" > "Volume" tab:
     - Add file mappings:
       - Map your known_hosts_gpustat to /root/.ssh/known_hosts
       - Map your id_ed25519 to /root/.ssh/id_ed25519
   - In "Advanced Settings" > "Port Settings" tab:
     - Map local port 48109 to container port 48109
   - In the "Command" field, enter the hostnames with usernames:
     ```
     user@a.example.com user@b.example.com
     ```
     (Or use `--no-verify-host user@a.example.com user@b.example.com` if not using host verification)

## 5. Access the Web Interface

Open your browser and navigate to:
```
http://your-synology-ip:48109
```

## 6. Managing the Container

```bash
docker stop gpustat-web    # Stop the container
docker start gpustat-web   # Start the container
docker restart gpustat-web # Restart the container
docker rm gpustat-web      # Remove the container
```

## Additional Notes

- Replace `user@a.example.com`, `user@b.example.com`, etc. with your actual username and host addresses
- If you encounter connection issues, check the container logs with: `docker logs gpustat-web`


License
-------

MIT License

Copyright (c) 2018-2023 Jongwook Choi

Copyright (c) 2025 yuna0x0
