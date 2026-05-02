# Copyright: 2015 Masatake YAMATO
# License: GPL-2

. ../utils.sh

CTAGS="$1"

if ${CTAGS} --quiet --options=NONE --list-features | grep -q afasdfasfasfsa; then
    echo
else
    skip "example: no such feature"
fi
