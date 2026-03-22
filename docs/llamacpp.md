# Llama.cpp with Intel

Following setup was tested on proxmox running an lxc container with B50 card

```bash
apt update && apt install curl intel-gpu-tools
```

docker-compose.yml

```bash
services:
  llama:
    image: ghcr.io/ggml-org/llama.cpp:server-intel
    container_name: llama
    restart: unless-stopped
    cap_add:
      - IPC_LOCK
    ports:
      - 8080:8080
    volumes:
      - ./models:/models
      - /dev/shm:/dev/shm
    devices:
      - /dev/dri/:/dev/dri/
    group_add:
      - "993" # render
      - "44"  # video
    environment:
      # Hardware Acceleration
      SYCL_DEVICE_FILTER: "level_zero:gpu:1"
      ONEAPI_DEVICE_SELECTOR: "level_zero:*"
      SYCL_PI_LEVEL_ZERO_USE_IMMEDIATE_COMMANDLISTS: "0"
      SYCL_PI_LEVEL_ZERO_USE_COPY_ENGINE: "1"
      GGML_SYCL_DEBUG: "0"
      GGML_SYCL_DEVICE: "1"

      # Performance Tuning B50
      GGML_SYCL_FORCE_MMQ: "1"
      GGML_SYCL_F16_AS_F32: "0"
      LLAMA_ARG_FLASH_ATTN: "true"
      LLAMA_ARG_CACHE_TYPE_K: "f16"
      LLAMA_ARG_CACHE_TYPE_V: "f16"
      LLAMA_ARG_BATCH: 1024
      LLAMA_ARG_UBATCH: 512

      LLAMA_ARG_CHAT_TEMPLATE: "chatml"
      LLAMA_ARG_JINJA: "true"
      LLAMA_ARG_PORT: 8080
      LLAMA_ARG_MODEL: /models/qwen2.5-coder-14b-instruct-q4_k_m.gguf
      LLAMA_ARG_MLOCK: true
      LLAMA_ARG_NO_MMAP: true
      LLAMA_ARG_N_GPU_LAYERS: "99"
```

Models to download from

[https://huggingface.co/models](https://huggingface.co/models)
