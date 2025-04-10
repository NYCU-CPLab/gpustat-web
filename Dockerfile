FROM python:3.12-alpine

# Install dependencies (openssh-client and build dependencies)
RUN apk add --no-cache openssh-client gcc musl-dev libffi-dev python3-dev

# Install setuptools which includes distutils
RUN pip install --no-cache-dir setuptools

# Set up SSH directory
RUN mkdir -p /root/.ssh && chmod 700 /root/.ssh

# Install gpustat-web
COPY . /app
WORKDIR /app
RUN pip install --no-cache-dir -e .

# Expose the default port
EXPOSE 48109

# Set up entrypoint without hardcoded hostnames
ENTRYPOINT ["gpustat-web", "--port", "48109"]

# Default to showing help if no hosts are provided
CMD ["--help"]
