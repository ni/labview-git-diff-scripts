#!/bin/bash
#
# This script generically handles any git diff. It accepts a diff command, a flag whether logging should be enabled,
# and the 7 parameters passed into GIT_EXTERNAL_DIFF: path old-file old-hex old-mode new-file new-hex new-mode
# (https://git-scm.com/docs/git#Documentation/git.txt-codeGITEXTERNALDIFFcode). With this information, it copies
# old/new files into the git repository as needed and executes the diff command with their "fixed" paths. This
# flexibility allows this wrapper script to launch any comparison tool e.g. LVCompare.exe.
#
# An example configuration follows:
#
# ~/.gitconfig:
# [diff "cg-diff"]
#	command = C:\\\\Users\\\\person\\\\GitDiffCommand.sh '\"C:\\\\Program Files\\\\National Instruments\\\\Shared\\\\LabVIEW Compare\\\\LVCompare.exe\" -nobdpos -nofppos \"$FIXED_OLD\" \"$FIXED_NEW\"' True
#
# <repo>/.gitattributes:
# *.vi diff=cg-diff

command=$1
interactive=$2
working_file=$3 # merged
old_file=$4     # local
# 5: old_sha
# 6: old_mode
new_file=$7     # remote
# 8: new_sha
# 9: new_mode

if [ "$interactive" == "True" ] && [ "$GIT_DIFF_PATH_TOTAL" -gt "1" ]; then
    echo "Viewing ($GIT_DIFF_PATH_COUNTER/$GIT_DIFF_PATH_TOTAL): '$working_file'"
    echo "Launch LVCompare [Y/n]? "
    read response # read -p (or echo -n) doesn't show the text properly inside git bash
    if [ "$response" == "n" ] || [ "$response" == "N" ]; then
        exit 0
    fi
fi

function format_path() {
    # Convert /c/path to c:/path so MSYS2 doesn't choke converting paths with single quotes
    echo $1 | sed 's|^/\([a-z,A-Z]\)/|\1:/|'
}

function log() {
    if [ "$interactive" != "True" ]; then
        echo $1
    fi
}

readonly NULL_FILE='/dev/null'

working_file_path=$(realpath "$working_file")
working_dir=$(dirname "$working_file_path")

# Copy temporary file(s) into working directory so diff tool can find dependencies e.g. subVIs
old_file_name=$(basename "$old_file")
if [ "$old_file" != $NULL_FILE ]; then
    cp "$old_file" "$working_dir"
    log "Copied old file '$old_file' into '$working_dir'"
    fixed_old_file=$(format_path "$working_dir/$old_file_name")
fi

new_file_name=$(basename "$new_file")
if [ "$new_file" != $NULL_FILE ]; then
    if [ "$new_file" != "$working_file" ]; then
        cp "$new_file" "$working_dir"
        log "Copied new file '$new_file' into '$working_dir'"
    fi
    fixed_new_file=$(format_path "$working_dir/$new_file_name")
fi

if [ "$new_file" != $NULL_FILE ]; then
    if [ "$old_file" == $NULL_FILE ]; then
        fixed_old_file=
    else
        fixed_old_file=${fixed_old_file//\//\\}
    fi
    fixed_new_file=${fixed_new_file//\//\\}
    log "Executing '$command' with FIXED_OLD '$fixed_old_file' and FIXED_NEW '$fixed_new_file'"
    # Execute the difftool command exposing fixed_new_file/fixed_old_file as variables
    FIXED_OLD="$fixed_old_file" FIXED_NEW="$fixed_new_file" bash -c "$command"
else
    echo "[DELETED]: $working_file"
fi
status=$?

# Clean up the copied temp files
if [ "$old_file" != $NULL_FILE ]; then
    rm "$fixed_old_file"
    log "Removed old file '$fixed_old_file'"
fi
if [ "$new_file" != "$working_file" ] && [ "$new_file" != $NULL_FILE ]; then
    rm "$fixed_new_file"
    log "Removed new file '$fixed_new_file'"
fi

exit $status