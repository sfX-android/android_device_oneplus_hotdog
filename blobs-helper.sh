#!/bin/bash

set -e

BLOBS="$1"

# default setting for removing blobs from the sources if not found
[ -z "$RMBL" ] && RMBL="false"
[ -z "$DEBUG" ] && DEBUG=0
[ -z "$DRY" ] && DRY=0

SKIP="mount-dynamic-rw.sh|unified-script.sh|event-log-tags|ashmemd.rc|task_profiles.json|twrp.flags"

[ -z "$BLOBS" ] && echo "missing arg: $0 \"<blob-path(s)>\"" && exit 4

for i in $(find recovery/root/system recovery/root/vendor -type f | grep -Ev "$SKIP");do
    BI=$(basename $i)
    FOUND=1
    find $BLOBS -type f -name $BI | grep -q $BI || FOUND=0
    if [ $FOUND -ne 1 ];then
	echo "WARNING: $BI not found in >$BLOBS<"
	[ "$RMBL" == "true" ] && [ "$DRY" == "0" ] && rm -v $i && echo "removed $BI as you set RMBL=true"
    else
	[ "$DEBUG" == "1" ] && echo processing $BI
    fi

    for b in $(find $BLOBS -type f -name $(basename $i));do
	NEWOD=$(od -An -t x1 -j 4 -N 1 $b | tr -d ' ')
	ORIGOD=$(od -An -t x1 -j 4 -N 1 $i | tr -d ' ')
	if [ "$NEWOD" == "$ORIGOD" ];then
	    [ "$DRY" == "0" ] && cp -v $b $i
	    [ "$DRY" == "1" ] && echo "would have copied: $b to: $i but DRY=1 so nothing happened"
	else
	    [ "$DEBUG" == "1" ] && echo "skipping $b due to arch mismatch ($NEWOD != $ORIGOD)"
	fi
    done
done

