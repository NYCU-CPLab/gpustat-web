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

# Running with Docker Compose and Basic Authentication

This setup provides gpustat-web behind a Caddy reverse proxy with basic authentication for added security.

## 1. Clone the repository

```bash
git clone https://github.com/NYCU-CPLab/gpustat-web.git
cd gpustat-web
```

## 2. Prepare SSH Files

### Create known_hosts File (For Host Verification)

Option A: Generate using ssh-keyscan:
```bash
# Create a new known_hosts file with your GPU hosts
mkdir ssh
ssh-keyscan a.example.com b.example.com > ssh/known_hosts
```

Option B: Copy from existing known_hosts:
```bash
# If your hosts are already in a known_hosts file
mkdir ssh
cp /path/to/known_hosts ssh/known_hosts
```

### Prepare SSH Key

Copy the SSH private key and set proper permissions:
```bash
cp /path/to/id_ed25519 ssh/id_ed25519
chmod 600 ssh/id_ed25519
```

## 3. Configure Environment Variables

Copy the example environment file and edit it with your settings:
```bash
cp .env.example .env
mkdir -p caddy/data caddy/config
```

Edit the `.env` file to set:
- Your GPU host addresses (`GPU_HOSTS`)
- Custom username and password for web access
- Domain name or address for Caddy (`SITE_ADDRESS`)
- Any other optional settings

**SITE_ADDRESS Options:**
- For local access: `SITE_ADDRESS=localhost` or `SITE_ADDRESS=:80`
- For a specific domain with automatic HTTPS: `SITE_ADDRESS=gpustat.example.com`
- For IP address access: `SITE_ADDRESS=192.168.1.100`

To generate a custom password hash:
```bash
docker run --rm caddy:2-alpine caddy hash-password
# Enter your password when prompted and copy the hash to your .env file
```

## 4. Start the Services

```bash
docker-compose up -d
```

## 5. Access gpustat-web

Open your browser and navigate to the address you specified in `SITE_ADDRESS`. You'll be prompted for the username and password you configured in the `.env` file.

- If using `localhost`: http://localhost
- If using a domain: https://yourdomain.com (automatically uses HTTPS)
- If using an IP address: http://your-ip-address

## 6. Managing the Services

```bash
# View logs
docker-compose logs

# Restart services
docker-compose restart

# Stop services
docker-compose down
```

## Troubleshooting

- **Domain issues**: If using a domain, ensure DNS records are properly configured.
- **SSL errors**: For domains, Caddy will attempt to automatically provision SSL certificates.
  Make sure ports 80 and 443 are accessible from the internet for this to work.
- **Connection issues**: Examine the logs with `docker-compose logs gpustat-web`.
- **Authentication problems**: Verify your username and password in the `.env` file.

License
-------

MIT License

Copyright (c) 2018-2023 Jongwook Choi

Copyright (c) 2025 yuna0x0
