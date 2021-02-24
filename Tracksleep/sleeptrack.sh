#!/bin/bash

STARTV=$1
ENDV=$2

START=0
END=0

SLEEPYDAY=0
OSX=0

TODAY=0
YESTERDAY=0

ARGS=("$@")

function checkArgs() {
  if [[ "${#ARGS[@]}" > 2 ]]; then
    echo "Too many arguments! Only 2 allowed."
    exit 1
  fi

  for i in "${ARGS[@]}"; do
    if ! [[ "${i}" =~ (^[0-9]{2}:[0-9]{2}$)|(^[0-9]{4}$) ]]; then 
      echo "${i} is not a valid time. Use 15:39 or 1539."
      exit 1
    fi
  done
}

function checkGdate {
  if type -p gdate > /dev/null; then
    OSX=1
    else
        OSX=0
        UNAMESTR=$(uname)
    if [[ "${UNAMESTR}" == "Darwin" ]]; then
      printf "%s\n" "You need coreutils. Install with:" "brew install coreutils"
      exit 1
    fi
  fi
}

function checkInt {
  string=$1
  case $string in
      ''|*[!0-9]*) echo "${1} is not an int!"; exit 255 ;;
      *) return 0 ;;
  esac
}

# remove :
function removeColon {
  START=${STARTV/#0/}
  START=${START/:/}
  END=${ENDV/#0/}
  END=${END/:/}
}

# add :
function addColon() {
  if ! [[ ${STARTV} =~ ^\d{2}:\d{2}$ ]]; then
    STARTV="${STARTV: 0:2}:${STARTV: -2}"
  fi

  if ! [[ ${ENDV} =~ ^\d{2}:\d{2}$ ]]; then
    ENDV="${ENDV: 0:2}:${ENDV: -2}"
  fi
}

function compareTime {
  if [[ $START -gt $END ]]; then
    STARTYDAY=1
  fi
}

function buildString() {
  if [[ $OSX -eq 1 ]]; then
    if [[ $STARTYDAY -eq 1 ]]; then
      SLEEPSTARTISO=$(gdate -d "-1 day" +%F)T$STARTV:00$(gdate +%:z)
    else
      SLEEPSTARTISO=$(gdate +%F)T$STARTV:00$(gdate +%:z)
    fi

    SLEEPENDISO=$(gdate +%F)T$ENDV:00$(gdate +%:z)
  else 
    if [[ $STARTYDAY -eq 0 ]]; then
      SLEEPSTARTISO=$(date -d "-1 day" +%F)T$STARTV:00$(date +%:z)
    else
      SLEEPSTARTISO=$(date +%F)T$STARTV:00$(date +%:z)
    fi

    SLEEPENDISO=$(date +%F)T$ENDV:00$(date +%:z)
  fi
}

checkArgs

#if MAC
checkGdate

removeColon
addColon

#sleepstart yesterday?
compareTime

buildString

timew track "${SLEEPSTARTISO}" - "${SLEEPENDISO}" "Sleep"