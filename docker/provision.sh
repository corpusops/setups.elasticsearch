#!/usr/bin/env bash
set -ex
rsync $RSYNC_OPTS "$_P.in/" "$_P/"
export ANSIBLE_FORCE_COLOR=1 PYTHONUNBUFFERED=1
log () {
    echo "${@}" >&2
}
do_install() {
    cd "$_P"
    $ANSIBLE_PLAYBOOK \
        $ANSIBLE_ARGS \
        -e @/tmp/ansible_params.yml \
        $ANSIBLE_FOLDER/$ANSIBLE_PLAY
}
apt update
do_up() {
    log "Upgrading corpusops as first try failed"
    cd "$COPS_ROOT"
    bin/install.sh -C -s
}
if [[ -n ${DO_UP-} ]] && ! do_up;then
    log "do re-upgrade failed"
    exit 3
fi
if do_install;then
    log "installed"
elif [ "x${COPS_ROOT}" != x"" ];then
    if ! do_up;then
        log "do upgrade failed"
        exit 3
    fi
    if do_install;then
        log "installed (2)"
    else
        log "fail install (2)"
        exit 4
    fi
else
    log "fail install"
    exit 5

fi
# vim:set et sts=4 ts=4 tw=80:
