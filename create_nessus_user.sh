#!/bin/bash
# Creates a Nessus user given STDIN

NESSUS_CLI="/opt/nessus/sbin/nessuscli"

# Create a nessus user.
nessusConfig() {
	USERNAME="${1}"
	GEN_PASS="${2}"

	if [ ! -f "${NESSUS_CLI}" ]; then
		echo "[Err] ${NESSUS_CLI} not found. Can't add user."
		return
	fi

	cat <<EOF | ${NESSUS_CLI} adduser ${USERNAME}
$GEN_PASS
$GEN_PASS
n

y
EOF
}

nessusConfig $1 $2
