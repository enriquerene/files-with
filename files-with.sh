#!/usr/bin/bash
source $LOCAL/bin/messages-template.sh

USAGE="files-with <regex_pattern> [<directory>[ <grep_around_lines>[ ...]]]\n\ndefault directory for searching is current one."
EXAMPLES=""
INSTRUCTIONS=$(GET_USAGE_INSTRUCTIONS "$USAGE" "$EXAMPLES")

PATTERN=''
if [ -z "$1" ]; then
    ERROR_MESSAGE 'No argument provided' "$INSTRUCTIONS"
else
    PATTERN="$1"
fi

shift

for arg in "$@"; do
    if [[ "$arg" == --* && "$arg" != "--type="* && "$arg" != "--lines="* ]]; then
        ERROR_MESSAGE 'invalid option provided' "$INSTRUCTIONS"
    fi
done

COUNTER=0
TYPE=''
NO_LINES=0
for arg in "$@"; do
    case $arg in
        --type=*)
            TYPE="${arg#*=}"
            COUNTER=$(( COUNTER + 1 ))
            ;;
        --lines=*)
            NO_LINES="${arg#*=}"
            COUNTER=$(( COUNTER + 1 ))
            ;;
    esac
done

[[ ! "$NO_LINES" =~ ^[0-9]+$ ]] && NO_LINES=0

for i in $(seq 1 $COUNTER); do
    shift
done

DIRECTORY_LIST="$@"
if [ -z "$DIRECTORY_LIST" ]; then
    DIRECTORY_LIST='.'
fi

for DIR in $DIRECTORY_LIST; do
    if [ -n "$TYPE" ]; then
        LIST=$(find $DIR -type f -name "*.$TYPE" -exec grep -l "$PATTERN" {} \;)
    else
        LIST=$(find $DIR -type f -exec grep -l "$PATTERN" {} \;)
    fi
    for FILE in $LIST; do
        if ! [[ "$NO_LINES" =~ ^[0-9]+$ ]]; then
            NO_LINES=0
        fi
        if [ "$NO_LINES" -eq 0 ]; then
            echo $FILE
        else
            echo "----------------------------------------------------"
            echo "Pattern found: '$PATTERN' in File: $FILE"
            echo "----------------------------------------------------"
            grep -C $NO_LINES --color=auto "$PATTERN" "$FILE"
        fi
    done
done
