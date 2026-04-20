#!/bin/sh
if [ -n "${CODESIGNING_FOLDER_PATH}" ] && [ -e "${CODESIGNING_FOLDER_PATH}" ]; then
  /usr/bin/xattr -cr "${CODESIGNING_FOLDER_PATH}" || true
fi

