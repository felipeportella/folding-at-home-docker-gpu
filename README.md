# Folding@Home for Petrobras Team

Folding@Home is a project focused on disease research including the CORVID-19 (Coronavirus).
Petrobras is helping the R&D by offering idle time of its own HPC environments to the Folding@Home project.
This repo contains scripts to help deploy Folding@Home in different environments.

## Acknowledgements

Most of the scripts here are a combination of [wandhydrant  Folding@home GPU Dockerfile](https://github.com/wandhydrant/folding-at-home-docker-gpu), [Nikolay Yurin's Folding@home CPU Dockerfile](https://github.com/yurinnick/folding-at-home-docker)
and the [BOINC Nvidia Dockerfile](https://github.com/BOINC/boinc-client-docker). Also <https://github.com/stefancrain/folding-at-home>

## Usage

### Singularity

```bash
make singularity-build
```

This command does it all (build the docker and then the singularity container).

#### Other

### Build docker the image locally

I did not set up anything pre-built on the Docker hub.

Please inspect the Dockerfile and build the image yourself:

```
cd <git-checkout>
docker build -t my-fah-nvidia-image .
```
or simply
```
make build
```

### and run it:

GPU access by containers went through several stages:
first direct export of /dev/dri and other devices; then
solutions with Docker "runtimes" (nvidia-docker v1
and v2); the current variant is the Nvidia Container
Toolkit. The latter is the only one I tested this with.

As for the BOINC Nvidia container, please:

1. Install Docker (19.03 or later);

2. Install the Nvidia drivers (so that "nvidia-smi" gives you output on the host);

3. Install the [Nvidia Container Toolkit](https://github.com/NVIDIA/nvidia-docker) (see "Usage" on the linked page to test nvidia-smi in a container).

Finally you can run this container:

```
docker run -d \
  --name folding-at-home \
  --gpus all \
  -h node \
  -e USER=Anonymous \
  -e TEAM=0 \
  -e ENABLE_GPU=true \
  -e ENABLE_SMP=true \
  --restart unless-stopped \
  my-fah-nvidia-image \
  --allow 0/0 --web-allow 0/0
```

``-h node`` sets an anonymous hostname instead of copying yours.

The last line means that Folding@home's web access will let everybody in,
but as the port is not exported, you can use it only from the Docker host,
pointing your browser at the container:

```
echo http://$(docker inspect  --format "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" folding-at-home):7396
```

## Parameters

- USER - Folding@home username (default: Anonymous)
- TEAM - Foldinghome team number (default: 0)
- PASSKEY - [optional] Folding@home [passkey](https://apps.foldingathome.org/getpasskey)
- ENABLE_GPU - Enable GPU compute (default: true)
- ENABLE_SMP - Enable auto-configuration of SMP slots (default: true)
- POWER - by default "full"; but you might want to switch to "medium" and see how hot your hardware gets (especially laptops). "light" did not use the GPU at all for me. You can always switch this in the web interface.

Additional configuration parameters can be passed as command line arguments. To get the full list of parameters run:

```
docker run my-fah-nvidia-image --help
```
