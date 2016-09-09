#!/bin/bash

###########
#  INFO   #
###########
INFO="
This script could be used to generate multiple colliding binary blobs and then
generate exploit: e.g. automatically add if else statements and different
payloads for all each colliding blob.
Open the CONFIG section of the script to configure it.
Resulting scripts' structure:
\$PREFIX_PRE
\$BINARY_BLOB
\$PREFIX_POST

\$IF_CLAUSE_PRE
\$COLLIDING_BLOB_1
\$IF_CLAUSE_POST
\$PAYLOAD_1
\$ELSEIF_CLAUSE_PRE
\$COLLIDING_BLOB_2
\$ELSEIF_CLAUSE_POST
\$PAYLOAD_2
\$ELSEIF_CLAUSE_PRE
\$COLLIDING_BLOB_3
\$ELSEIF_CLAUSE_POST
\$PAYLOAD_3
...
\$ELSE_CLAUSE
\$PAYLOAD_ELSE

\$ENDING"

###########
# CONFIG  #
###########

FASTCOLL='./fastcoll' # path to fastcoll

N=2 # Amount of colliding files generated would be 2^N
LAST_ID=`echo "2^$N" | bc`

WORK_FOLDER="./collisions"
COLLISIONS_FOLDER="${WORK_FOLDER}/coll"
sname="${COLLISIONS_FOLDER}/suffix"
pname="${COLLISIONS_FOLDER}/prefix"

# Setup for python. Change as seems appropriate
PREFIX_PRE="#!/usr/bin/python
# -*- coding: utf-8 -*-
blob = '''
"
PREFIX_POST="'''"

IF_CLAUSE_PRE="\nif blob == '''\n"
IF_CLAUSE_POST="''':\n"

ELSEIF_CLAUSE_PRE="\nelif blob == '''\n"
ELSEIF_CLAUSE_POST="''':\n"

ELSE_CLAUSE="\nelse:\n"

ENDING=""

function gen_payload_by_id() {
	local COLLISION_ID=$1
	printf "\tprint(\"Bank account balance: %s\$\")\n" $COLLISION_ID
}

function gen_else_payload() {
	printf "\tprint(\"Tough luck\")\n"
}

function get_filename_by_id() {
	local COLLISION_ID=$1
	printf "file_%s.py" $COLLISION_ID
}

#################
# Functionality #
#################

# Not necessary to change

function gen_prefix_pre(){
	echo -ne "$PREFIX_PRE" > $pname
}

function prep() {
	mkdir -p $WORK_FOLDER
	mkdir -p $COLLISIONS_FOLDER
	if ! [ -x "$FASTCOLL" ]; then
		echo "Fastcoll by path \"${FASTCOLL}\" is not executable(does it exist?)."
		exit 1
	fi
}

function gen_collisions() {
	#generate first 2 colliding files
	$FASTCOLL -p "$pname" -o "${COLLISIONS_FOLDER}/0" "${COLLISIONS_FOLDER}/1"

	# generate N more colliding pairs, given prefix
	PREV_POWER=0
	ITERATIONS=${N}
	((ITERATIONS--))
	for i in `seq 1 ${ITERATIONS}`; do
		CUR_POWER=`echo "2^$i" | bc`
		((CUR_POWER--))
		CUR_POWER_BIN=$(echo "obase=2;$CUR_POWER" | bc)
		$FASTCOLL -p "${COLLISIONS_FOLDER}/$CUR_POWER_BIN" -o "${COLLISIONS_FOLDER}/tmp.full.0" "${COLLISIONS_FOLDER}/tmp.full.1"
		tail -c 128 "${COLLISIONS_FOLDER}/tmp.full.0" > "${COLLISIONS_FOLDER}/tmp.0"
		tail -c 128 "${COLLISIONS_FOLDER}/tmp.full.1" > "${COLLISIONS_FOLDER}/tmp.1"
 		for CUR_FILE in `seq 0 $CUR_POWER`; do
 			UNPAD_FILE_BIN=$(echo "obase=2;$CUR_FILE" | bc)
 			CUR_FILE_BIN=`printf "%0${i}d" "$UNPAD_FILE_BIN"`
			echo "Generating intermidiate collision $CUR_FILE_BIN"
			cp "${COLLISIONS_FOLDER}/$CUR_FILE_BIN" "${COLLISIONS_FOLDER}/${CUR_FILE_BIN}0"
			cat "${COLLISIONS_FOLDER}/tmp.0" >> "${COLLISIONS_FOLDER}/${CUR_FILE_BIN}0"
			cp "${COLLISIONS_FOLDER}/$CUR_FILE_BIN" "${COLLISIONS_FOLDER}/${CUR_FILE_BIN}1"
			cat "${COLLISIONS_FOLDER}/tmp.1" >> "${COLLISIONS_FOLDER}/${CUR_FILE_BIN}1"
		done
		PREV_POWER=$CUR_POWER
		((PREV_POWER++))
		sleep 1
	done

	# copy resulting colliding files to final location
	LAST_COL_FILE=`echo "2^$N" | bc`
	((LAST_COL_FILE--))
	ID=1
	PREFIX_SIZE=$(wc -c <"${COLLISIONS_FOLDER}/prefix")
	for i in `seq 0 $LAST_COL_FILE`; do
		UNPAD_CUR_BIN_I=$(echo "obase=2;$i" | bc)
		CUR_BIN_I=`printf "%0${N}d" "$UNPAD_CUR_BIN_I"`
		cp "${COLLISIONS_FOLDER}/$CUR_BIN_I" "${WORK_FOLDER}/$(get_filename_by_id $ID)"
	
		# strip the prefix from blobs for later usage
		dd if="${COLLISIONS_FOLDER}/$CUR_BIN_I" of="${COLLISIONS_FOLDER}/blob_$ID" bs=1 skip="$PREFIX_SIZE"

		((ID++))
	done
}

function gen_suffix() {
	# get last ID
	echo -ne "$PREFIX_POST" > $sname

	echo -ne "$IF_CLAUSE_PRE" >> $sname
	cat "${COLLISIONS_FOLDER}/blob_1" >> $sname 
	echo -ne "$IF_CLAUSE_POST" >> $sname
	echo -ne "$(gen_payload_by_id 1)" >> $sname

	for ID in `seq 2 $LAST_ID`; do
		echo -ne "$ELSEIF_CLAUSE_PRE" >> $sname
		cat "${COLLISIONS_FOLDER}/blob_$ID" >> $sname 
		echo -ne "$ELSEIF_CLAUSE_POST" >> $sname
		echo -ne "$(gen_payload_by_id $ID)" >> $sname
	done

	echo -ne "$ELSE_CLAUSE" >> $sname
	echo -ne "$(gen_else_payload)" >> $sname

	echo -ne "$ENDING" >> $sname
}

function append_suffix() {
	for ID in `seq $LAST_ID`; do
		cat "${COLLISIONS_FOLDER}/suffix" >> "${WORK_FOLDER}/$(get_filename_by_id $ID)"
	done
}

########
# MAIN #
########

if [[ ( $@ == "--help") ||  $@ == "-h" ]]; then
	echo "$INFO"
	exit 0
fi

prep
gen_prefix_pre
gen_collisions
gen_suffix
append_suffix

