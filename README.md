# Docker based image for elasticsearch

## USE/Install with makina-states
- makina-state deployment (legacy) can be found in .salt

## corpusops/elasticsearch (CURRENT)
### Description
This setups a nginx reverse proxy on http/https that forward requests
to an underlying elasticsearch worker.

### Run this image through docker

- Create the data dir & the ansible params file
  that will reconfigure elasticsearch & nginx before starting up

    - See [defaults](/ansible/roles/elasticsearch/defaults/main.yml)

    ```sh
    mkdir -p local/data local/setup
    cat >local/setup/reconfigure.yml << EOF
    ---
    cops_es_env:
      ES_HTTP_PORT: 9200
    EOF
    ```
- On the first run, the ``data`` directory **MUST BE EMPTY**
- To pull/run this image

    ```sh
    # docker pull corpusops/elasticsearch:<TAG>
    docker pull corpusops/elasticsearch:5.4.0
    docker run \
      -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
      -v $(pwd)/local/setup:/setup:ro \
      -v $(pwd)/local/data:/srv/projects/elasticsearch/data \
      --security-opt seccomp=unconfined \
      -P -d -i -t corpusops/elasticsearch:5.4.0
    ```

### Build this image
- Install ``hashicorp/packer`` && ``docker``
- get the code
- run ``./bin/build.sh``

### Image provision notes
- See ``.ansible``, the image is (re)-configured using ansible.

## ansible
- Docker uses the [elasticsearch role](ansible/roles/elasticsearch) underthehood which
  is generic and is not docker specific.
- You may use directly this role to provision elasticsearch on another host type.

### Steps to create cops docker compliant images
- Copy/adapt from another image:
    - ``./ansible``
    - ``./docker``
    - ``./bin/env.sh``
    - ``./bin/build.sh``
- Delete ``docker/packer``
- Maybe adapt ``bin/buid.sh``
- Maybe adapt ``docker/provision.sh``
- Feed ``ansible/``
- Edit/adapt ``docker/packer.json``
    - take care that the ``__VERSION__`` placeholder is used correcly
    - edit the inline shell script to adapt the generated ``ansible_params.yml``
      ansible variable file accordingly to your provision playbooks & roles.
- Launch until success bin/build.sh which launch [docker_build_chain](https://github.com/corpusops/corpusops.bootstrap/blob/master/hacking/docker_build_chain.py) ([doc](https://github.com/corpusops/corpusops.bootstrap/blob/master/doc/docker_build_chain.md))
- Create & feed ``docker/IMAGES.json``
- Verify after build:
    - generated: ``docker/packer/*.json``
    - produced docker images

