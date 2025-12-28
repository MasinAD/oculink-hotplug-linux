#!/usr/bin/env bash
DIRNAME=$(dirname -- "${BASH_SOURCE[0]}")
REALPATH=$(realpath "${DIRNAME}")
NESTED=$( realpath $(dirname -- "${BASH_SOURCE[0]}") )
echo "${DIRNAME}"
echo "${REALPATH}"
echo "${NESTED}"
