# Gitlab runner template config

```
concurrent = 2
check_interval = 0
shutdown_timeout = 0

[session_server]
  session_timeout = 1800

[[runners]]
  name = "gitlab-default-ubuntu-runner"
  url = "https://gitlab.example.com"
  id = 3
  token = "glrt-P4Ciq2-Tbk4-VxxxxxxxxxxxxxdTo3Cw.01.1207yocde"
  token_obtained_at = 2025-07-17T20:48:32Z
  token_expires_at = 0001-01-01T00:00:00Z
  executor = "docker"
  limit = 2
  environment = ["DOCKER_DRIVER=fuse-overlayfs", "DOCKER_HOST=unix:///var/run/docker.sock"]
  [runners.cache]
    Insecure = false
    MaxUploadedArchiveSize = 0
    [runners.cache.s3]
    [runners.cache.gcs]
    [runners.cache.azure]
  [runners.docker]
    tls_verify = false
    image = "alpine:latest"
    pull_policy = "if-not-present"
    privileged = true
    disable_entrypoint_overwrite = false
    oom_kill_disable = false
    disable_cache = false
    volumes = ["/var/run/docker.sock:/var/run/docker.sock", "/cache"]
    shm_size = 0
    network_mtu = 0

    [[runners.docker.service]]
      name = "docker:dind"
      alias = "docker"
```
