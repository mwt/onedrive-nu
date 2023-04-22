# Sync folder and notify of changes

This repository contains a script that will sync a folder from a remote and notify you of changes. The purpose of this is to get a push notification when files change on disk. This is useful for me because changes in this folder typically indicate that I have work to do.

This script requires: shell, rclone, jq, and [smplxmpp](https://codeberg.org/tropf/smplxmpp).

The script is intended to be run using cron.
