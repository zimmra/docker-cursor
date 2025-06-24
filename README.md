# Work-In-Progress
## Use at Your Own Risk

### Cursor Code Editor for Web Browser / Kasm Workspace
#### Bundled with Firefox, Thunar File Explorer, and GitHub Desktop for complete development environment

Can be found at https://hub.docker.com/r/pzubuntu593/docker-cursor

Based off LSIO's implementation of [KasmVNC w/ Audacity](https://github.com/linuxserver/docker-audacity)


## Docker Compose Example
```yaml
---
services:
  cursorai:
    image: pzubuntu593/docker-cursor:latest
    container_name: Cursor AI
    privileged: true
    security_opt:
      - seccomp:unconfined #optional
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=America/New_York
      - TITLE="Cursor AI"
    volumes:
      - /media/docker/configs/cursorai:/config
    devices:
      - /dev/dri:/dev/dri 
    ports:
      - 3000:3000
    restart: unless-stopped
```

Also can be used seamlessly with Kasm Workspaces due to using the kasm-vnc base image

WARNING: This will throw various erros in the logs but it appears to be superficial, can be ignored for now
