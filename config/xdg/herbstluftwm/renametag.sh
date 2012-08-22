#!/bin/bash

function hc() {
    herbstclient "$@"
}

tags=$(hc tag_status)
current=""

for i in ${tags}; do
    if [[ ${i:0:1} == '#' ]]; then
        current=${i}
        break
    fi
done

# If : is in current tag
if [[ "$current" == *:* ]]; then
    num=$(echo $current | sed -e 's/#\([^:]*\):.*/\1/')
    name=$(echo $current | sed -e 's/#[^:]*:\(.*\)/\1/')

    old_tag=${num}:${name}
    new_name=$(echo ${name} | dmenu -p "Rename #${num}: ")
    new_tag=${num}:${new_name}
else
    old_tag=$(echo ${current} | sed -e 's/^#//')
    new_name=$(echo "" | dmenu -p "Rename #${old_tag}: ")
    new_tag="${old_tag}:${new_name}"
fi

hc rename "${old_tag}" "${new_tag}"
hc rename ${num}:${name} "${num}:${new_name}"
