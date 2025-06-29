#!/bin/bash

if [ -f .env ]; then
    set -a && source .env && set +a
fi

rm -rf build/

function partial {
    PARTIAL_NAME=$1

    shift

    eval "cat <<PAGEPRESS_EOF
$(<partials/$PARTIAL_NAME.html)
PAGEPRESS_EOF
"
}

function escape {
    echo $@ | sed "s/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/\"/\&quot;/g; s/'/\&#39;/g"
}

function IF {
    if [ "$2" = "=" ]; then if [ "$1" = "$3" ]; then echo $4; else echo $6; fi; fi
    if [ "$2" = "!=" ]; then if [ "$1" != "$3" ]; then echo $4; else echo $6; fi; fi
}

function pagepress_renderPage {
    mkdir -p build/$(dirname $1)

    export -f partial escape

    eval "cat <<PAGEPRESS_EOF
$(<pages/${1})
PAGEPRESS_EOF
" > build/${1}
}

if [ -d pages ]; then
    for page in $(find pages -type f -name "*"); do
        filename=${page##pages/}
        pagepress_renderPage $filename
    done
fi

if [ -d media ]; then
    cp -r media build/media
fi

if [ "$1" = "serve" ]; then
    python3 -m http.server $2 --directory build
fi