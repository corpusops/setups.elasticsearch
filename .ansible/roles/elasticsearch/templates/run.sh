#!/usr/bin/env bash
# {{ansible_managed}}
# {% set data = cops_elasticsearch_vars %}

set -e
cd $(dirname $0)/..
if [ -e bin/es.env ];then . bin/es.env;fi
ES_JAVA_VARS="
ES_MIN_MEM
ES_MAX_MEM
ES_HEAP_SIZE
ES_HEAP_NEWSIZE
ES_DIRECT_SIZE
ES_USE_IPV4
ES_GC_OPTS
ES_GC_LOG_FILE
JAVA_OPTS"
jopts=""
for i in $ES_JAVA_VARS;do
    if [[ -n "$i" ]];then
        val=$(eval "echo \$${i}")
        if [[ -n ${val} ]];then
            echo ${i}
        fi
        if [[ -n $val ]];then
            case $i in
                JAVA_OPTS|ES_GC_OPTS)
                    jopts="$jopts $val";;
                ES_GC_LOG_FILE)
                    jopts="$jopts -XX:MaxDirectMemorySize=$val";;
                ES_DIRECT_SIZE)
                    jopts="$jopts -XX:MaxDirectMemorySize=$val";;
                ES_HEAP_NEWSIZE)
                    jopts="$jopts -Xmn$val";;
                ES_MIN_MEM)
                    jopts="$jopts -Xms$val";;
                ES_MAX_MEM)
                    jopts="$jopts -Xmx$val";;
                ES_HEAP_SIZE)
                    jopts="$jopts -Xms$val -Xmx$val";;
                ES_USE_IPV4)
                    jopts="$jops -Djava.net.preferIPv4Stack=true";;
            esac
            eval "unset $i"
        fi
    fi
done <<< "$ES_JAVA_VARS"

vv export  ES_JAVA_OPTS="${ES_JAVA_OPTS} ${jopts}"
set -x
vv exec $ES_LAUNCHER -p ${ES_PID_DIR}/elasticsearch.pid
# vim:set et sts=4 ts=4 tw=80:
