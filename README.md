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
    - We use here those volume
        - a simple volume ``setup`` to share a configuration file to reconfigure fles
        - All other volumes may be [docker volumes](https://docs.docker.com/engine/admin/volumes/volumes/)
          as they need at first to be prepopulated from the image content.

    ```sh
    mkdir -p local/data local/setup
    cat >local/setup/reconfigure.yml << EOF
    ---
    cops_es_env:
      ES_HTTP_PORT: 9200
    EOF
    ```
- On the first run, the ``data`` directory **MUST BE EMPTY**
- To pull & run this image
  Note that The folllowing command implicitly create 2 volumes against local directories and the goal
  is to prepopulate the directories from the image content on the first run.<br/>
  Indeed, the -v option does not feed host directories, even if empty from an image content.

    ```sh
    # docker pull corpusops/elasticsearch:<TAG>
    docker pull corpusops/elasticsearch:5.4.0
    N="my-elasticsearch-container"
    docker run \
      --name=${N} \
      -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
      -v $(pwd)/local/setup:/setup:ro \
      --mount volume-driver=local,volume-opt=type=none,volume-opt=device=$(pwd)/local/data,volume-opt=o=bind,source=${N}-data,target=/srv/projects/postgresql/data \
      --security-opt seccomp=unconfined \
      -P -d -i -t corpusops/elasticsearch:5.4.0
    ```

- In development, you can add the following knob to indicate that you want to
  edit files.

    ```sh
    -e SUPEREDITORS=$(id -u)
    ```

### Build this image
- Install ``hashicorp/packer`` && ``docker``
- get the code
- run ``./bin/build.sh``

### Image provision notes
- See ``.ansible``, the image is (re)-configured using ansible.

### A note on file rights
- Docker file rights are a nightmare for developers
- We provide a very way to use, specially when you are on localhost,<br/>
  activly developping  your app to edit the files of the container,<br/>
  thanks to POSIX ACLS.
- You need two things to configure your app (normally good by dedfault):
    - ``cops_postgresql_supereditors_paths`` Tell which paths will be "opened" to the outside user(s) if default does not suit your need
    - ``cops_postgresql_supereditors`` Tell which user(s), (attention **UIDS**).<br/>
      The aforementioned command to launch container includes the ``SUPEREDITORS`` env var configured with the loggued in user
- Those settings can be overriden via ``setup/reconfigure.yml``
- File rights are enforced upon container (re-)start
- If file rights are messed up too much, you can try this to enforce them

    ```sh
    docker exec -e SUPEREDITORS="$(id -u)" -ti <mycontainer> bash
    /srv/projects/<myproject>/fixperms.sh
    ```

## ansible
- Docker uses the [elasticsearch role](ansible/roles/elasticsearch) underthehood which
  is generic and is not docker specific.
- You may use directly this role to provision elasticsearch on another host type.

### Steps to create cops docker compliant images
- We use via  bin/build.sh which launch [docker_build_chain](https://github.com/corpusops/corpusops.bootstrap/blob/master/hacking/docker_build_chain.py) ([doc](https://github.com/corpusops/corpusops.bootstrap/blob/master/doc/docker_build_chain.md#sumup-steps-to-create-corpusops-docker-compliant-images))


