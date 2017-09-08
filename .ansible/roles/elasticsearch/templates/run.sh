#!/usr/bin/env bash
# {{ansible_managed}}
# {% set data = cops_elasticsearch_vars %}

set -e
cd $(dirname $0)/..
if [ -e bin/es.env ];then . bin/es.env;fi
vv exec $ES_LAUNCHER -p ${ES_PID_DIR}/elasticsearch.pid
# vim:set et sts=4 ts=4 tw=80:
