#!/bin/bash
########################################################################################################
#
# parses all given directories for blobs found here, then copies any blob found from the source dir
# then checks for blobs dependencies and copies these here as well.
#
# requires sfX-Android buildtools:
# git clone https://github.com/sfX-android/android_buildtools external/buildtools
#
# Copyright 2023 - steadfasterX <steadfasterX | at | gmail #DOT# com>
#
#
# Example dry run:
#
#  DRY=1 ./blobs-helper.sh "/home/androidsource/do-not-touch/axp/Build/LineageOS-20.0/vendor/oneplus/sm8150-common /home/androidsource/do-not-touch/axp/Build/LineageOS-20.0/vendor/oneplus/hotdog"
#
# Example real run:
#
# ./blobs-helper.sh "/home/androidsource/do-not-touch/axp/Build/LineageOS-20.0/vendor/oneplus/sm8150-common /home/androidsource/do-not-touch/axp/Build/LineageOS-20.0/vendor/oneplus/hotdog"
#
########################################################################################################
# do not set -e

CPBLOBS=()
ADEPBLOBS=()
DEPBLOBS=()
MISSBLOBS=()
RET=0
BLOBS="$1"
BLOBSX=../../../external/buildtools/blobs.sh

# default setting for removing blobs from the sources if not found
[ -z "$RMBL" ] && RMBL="false"
[ -z "$DEBUG" ] && DEBUG=0
[ -z "$DRY" ] && DRY=0

SKIP="gpfspath_oem_config.xml|manifest.xml|mount-dynamic-rw.sh|unified-script.sh|event-log-tags|ashmemd.rc|task_profiles.json|twrp.flags"

[ -z "$BLOBS" ] && echo "missing arg: $0 \"<blob-path(s)>\"" && exit 4

for i in $(find recovery/root/system recovery/root/vendor -type f | grep -Ev "$SKIP");do
    BI=$(basename $i)
    FOUND=1
    find $BLOBS -type f -name $BI | grep -q $BI || FOUND=0
    if [ $FOUND -ne 1 ];then
	MISSBLOBS[1]+="$MISSBLOBS $i"
	[ "$RMBL" == "true" ] && [ "$DRY" == "0" ] && rm -v $i && echo "removed $BI as you set RMBL=true and its missing in the given source path(s)"
    else
	[ "$DEBUG" == "1" ] && echo processing $BI
    fi

    for b in $(find $BLOBS -type f -name $(basename $i));do
	NEWOD=$(od -An -t x1 -j 4 -N 1 $b | tr -d ' ')
	ORIGOD=$(od -An -t x1 -j 4 -N 1 $i | tr -d ' ')
	if [ "$NEWOD" == "$ORIGOD" ];then
	    CPBLOBS[1]+="$CPBLOBS ${b}:${i}"
	    for cbpath in $BLOBS; do
		DEPB=$($BLOBSX "$cbpath" "$b" 2>/dev/null)
		for dep in $DEPB;do
		    ADEPBLOBS[1]+="$ADEPBLOBS ${dep}"
		done
	    done
	else
	    [ "$DEBUG" == "1" ] && echo "skipping $b due to arch mismatch ($NEWOD != $ORIGOD)"
	fi
    done
done
RET=$((RET + $?))
#echo -e "reals: ${CPBLOBS[@]}\n\ndeps:${DEPBLOBS[@]}\n"
for dep in ${ADEPBLOBS[@]};do
    echo "${CPBLOBS[@]}" | grep -q "${dep/*\/}"
    if [ $? -ne 0 ];then 
	[ "$DEBUG" == "1" ] && echo "${dep/*\/} not found in array"
	DEPBLOBS[1]+="$DEPBLOBS ${dep}:recovery/root/vendor/UNKNOWN"
	mkdir -p recovery/root/vendor/UNKNOWN
    else
	[ "$DEBUG" == "1" ] && echo "${dep/*\/} found in array"
    fi
done

CPSRC=$(echo "${CPBLOBS[@]} ${DEPBLOBS[@]}" | tr " " "\n" | sort -u | tr -d " " | tr "\n" " ")

for cf in $CPSRC;do
    [ "$DRY" == "0" ] && cp -v ${cf/:*} ${cf/*:}
    [ "$DRY" == "1" ] && echo "would have copied: ${cf/:*} to: ${cf/*:} but DRY=1 so nothing happened"
done
RET=$((RET + $?))

if [ ! -n "${MISSBLOBS[@]}" ];then
    echo "cool all blobs found, go ahead"
else
    echo -e "\nWARNING: The following blobs could not be found in the sources:"
    echo -e "(searched in: $BLOBS)\n"
    for m in ${MISSBLOBS[@]};do
	echo "- ${m}"
    done
    echo -e "\nsingle line, just names (ensure you grab the right lib arch!):\n$(for mb in ${MISSBLOBS[@]};do printf ${mb/*\/};done)"
    echo
fi
RET=$((RET + $?))

echo $0 finished with $RET
