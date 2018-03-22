#!/bin/bash

# AUTHOR JACKSON WIEBE

# COPYRIGHT 2018 JACKSON WIEBE

# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this
# list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors
# may be used to endorse or promote products derived from this software without
# specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# Main
tomato()
{
    LOGFILE="$HOME/nightshade.log"
    SET_TERMINAL_TITLE="\033]0;Nightshade\007"
    WRITE_STATUS="\033]r".
    
    # Assign DEFAULTS to variables
    
    REPEAT=3     #repeat work timer 3 times, with 2 breaks in between.
    TIME="1200"  #20 minutes
    BREAK="240"  #4 minutes
    TASK="'hacking the pentagon'"

    # Print HELP or VERSION
    
    if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
	cat <<EOF
SYNOPSIS 
	pomo [COMMANDS] [TASK]

DESCRIPTION
	Starts a pomodoro timer for the given TASK.
	
	Mandatory  arguments  to  long  options are mandatory for short options too.
 
	-t, --time=TIME
		sets the work timer to the given time; e.g.,
		'--time=20m' will set the timer for 20 minutes.

	-b, --break=TIME
		sets the break timer to the given time; e.g.,
		'--break=4m' will set the break timer for 4 minutes.

	-r, --repeat=REPETITIONS		
		sets the number of repetitions of pomodoro timers for the given task; e.g.,
		'repeat=4' will run the work timer 4 times, with 3 break timers interspersed.
EOF
	return
    fi
    if [[ "$1" == "-v" ]] || [[ "$1" == "--version" ]]; then
	cat <<EOF
VERSION: 0
AUTHOR:  Jack Wiebe     
MODIFIED: March 25, 2018
EOF
	return
    fi

    # READ LOOP for OPTIONS and TASK

    while :
    do
	case "$1" in
	    -t=* | --time=*)
		TIME=${1##*=}
		case "$TIME" in
		    *m)
			TIME=$((${TIME%%m}*60))
			;;
		    *s)
			TIME=${TIME%%s}
			;;
		esac
		shift
		;;
	    -b=* | --break=*)
		BREAK=${1##*=}
		case "$BREAK" in
		    *m)
			BREAK=$((${BREAK%%m}*60))
			;;
		    *s)
			BREAK=${BREAK%%m}
			;;
		esac

		shift
		;;
	    -r=* | --repeat=*)
		REPEAT=${1##*=}
		shift
		;;
	    -*)
		echo "ERROR: Unknown option: $1" >&2
		return 1
		;;
	    *)
		TASK=${@:-$TASK}
		break
		;;	   
	esac
    done

    # MAIN LOOP LOGIC

    for ((; REPEAT > 0; REPEAT-- ));
    do
	(work $TIME "$TASK") || return 0;
	if (( REPEAT > 1 )); then
	    breather $BREAK
	else
	    complete "$TASK"
	fi
    done
}

# Handles the timer and input during a WORK period for a given TASK.
work()
{
    TIME=$1
    TASK=$2

    #Change the name of the Terminal and bring it to the front.
    printf "$SET_TERMINAL_TITLE"
    xdotool search --name ^Nightshade windowactivate
    
    read -p "Press enter to begin $TASK..."
    logStartWork "$TASK"
    
    # Start time for PAUSE & RESUME
    SECONDS=0

    declare INPUT
    #SET and RESTORE timer value when PAUSED
    declare PAUSE 

    for ((; SECONDS <= TIME;)); do
	#Poll for PAUSE
	read -t 1 -n 1 -s INPUT
	if [[ $INPUT == "p" ]];
	then
	    logBreak "$TASK" $TIME
	    PAUSE=$SECONDS;
	    read -p "*** Paused... press enter to continue."
	    SECONDS=$PAUSE;
	    logResume "$TASK" $TIME
	fi
	if [ "$INPUT" = $'\033' ];
	then
	    read -t 0.00001 -n 1 -s INPUT
	    if [ "$INPUT" = '' ];
	    then
		logComplete "$TASK" $TIME
		return 1 # freedom...
	    fi
	fi
    done

    logWork "$TASK" $TIME
}

# Handles setting the screen dim for the given BREAK period.
breather()
{
    BREAK=$1

    notify-send "Break-time" "Take $BREAK to relax" 
    sleep 2s
    xbacklight =1 -steps 10
    sleep $BREAK
    xbacklight =100 -steps 1
    xbacklight =1 -steps 1
    xbacklight =100 -steps 1 
}

# Handles returning the screen to normal after accmplishing the TASK.
complete()
{
    TASK=$1
    TIME=$2

    xbacklight =100 -steps 1
    xbacklight =1 -steps 1
    xbacklight =100 -steps 1
    
    notify-send "$TASK completed" "Good work, take a breather."
    logComplete "$TASK" $TIME
}

# Writes to the log file that a TASK was engaged with.
logWork()
{
    log "Engaged $1 for $2"
}

logStartWork()
{
    printf "....................\n" >> $LOGFILE
    log "Started working on $1"
}

# Writes to the log file that a TASK was successfully accomplished.
logComplete()
{
    log "Accomplished $1"
}

logBreak()
{
    log "Took a break from $1"
}

logResume()
{
    log "Resumed work on $1"
}

log()
{
    MSG=$1

    timeStamp STAMP
    echo -e "$STAMP: $MSG" >> $LOGFILE
}

# Generates and returns a timestamp
# @return returns timestamp
timeStamp()
{
    __resultVar=$1
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    eval $__resultVar="'$timestamp'"
}

