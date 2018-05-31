# Docker based image for elasticsearch

## USE/Install with makina-states
- makina-state deployment (legacy) can be found in .salt

## corpusops/elasticsearch (CURRENT)
### Description
This setups a nginx reverse proxy on http/https that forward requests
to an underlying elasticsearch worker.


### ajust some system conf

Mostly for elasticsearch5+

- System wide

    ```sh
    sudo sysctl -w vm.max_map_count=262144
    ```

- Or by docker CLI setting if possible

    ```
    --sysctl vm.max_map_count=262144
    ```

### Volumes
- We use two main volumes!
    - a volume ``setup`` to share a configuration file to reconfigure fles
    - a volume ``data`` to store user data

#### Initialise setup volume
- To reconfigure any setting upon container (re)start, create/edit ``/setup/reconfigure.yml``
    - See [defaults](/ansible/roles/elasticsearch/defaults/main.yml)

- exemple:

    ```sh
    mkdir -p local/setup
    cat >local/setup/reconfigure.yml << EOF
    ---
    cops_es_env:
      ES_HTTP_PORT: 9200
    EOF
    ```

- to disable the nginx vhost:

    ```
    # cops_elasticsearch_has_reverse_proxy: false
    ```

#### Initialise user data volumes
- You need to preseed some volumes from your image before running it
    - data

        ```sh
        mkdir -p local/data
        docker run --rm  -v $PWD/local/data:/ldata --entrypoint rsync \
            corpusops/elasticsearch:5.4.0 \
            "/srv/projects/elasticsearch/data/" "/ldata/" \
            -av --delete --exclude "pwd_*" --delete-excluded
        ```

### Run this image through docker
- To pull & run this image
  Note that The folllowing command implicitly create 2 volumes against local directories and the goal
  is to prepopulate the directories from the image content on the first run.<br/>
  Indeed, the -v option does not feed host directories, even if empty from an image content.

    ```sh
    # docker pull corpusops/elasticsearch:<TAG>
    docker pull corpusops/elasticsearch:5.4.0
    docker run \
      --name=my-elasticsearch-container \
      -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
      -v "$(pwd)/local/setup:/setup:ro" \
      -v "$(pwd)/local/data:/srv/projects/elasticsearch/data" \
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
    - ``cops_elasticsearch_supereditors_paths`` Tell which paths will be "opened" to the outside user(s) if default does not suit your need
    - ``cops_elasticsearch_supereditors`` Tell which user(s), (attention **UIDS**).<br/>
      The aforementioned command to launch container includes the ``SUPEREDITORS`` env var configured with the loggued in user
- Those settings can be overriden via ``/setup/reconfigure.yml``
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


