
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

trap 'pause' SIGTERM SIGINT
    
# Global variables

declare __TOMO_REPEAT
declare __TOMO_TIME
declare __TOMO_BREAK
declare __TOMO_TASK
declare __TOMO_RESUME
declare __TOMO_REMAINDER



tomo()
{
    source .e
    
    if ($__TOMO_RESUME); then
	resume
    fi
    
    __TOMO_RESUME=false
    # Assign DEFAULTS to variables
    
    REPEAT=1
    TIME="20m"
    BREAK="4m"
    TASK="hacking the pentagon"

    # Print HELP or VERSION
    
    if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
	cat <<EOF
SYNOPSIS 
	pomo [COMMANDS] [TASK]

DESCRIPTION
	Starts a pomodoro timer for the given TASK.
 
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
			TIME=${TIME%%m}
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
		TASK=${@:-TASK}
		break
		;;	   
	esac
    done

    # SAVE TO GLOBALS
    
    __TOMO_TIME=$TIME
    __TOMO_BREAK=$BREAK
    __TOMO_TASK=$TASK

    # MAIN LOOP LOGIC

    for ((;REPEAT > 0;REPEAT--));
    do
	run $TIME $BREAK $TASK
    done
}

run()
{
    TIME=$1
    BREAK=$2
    TASK=$3

    read -p "Press enter to start $TASK..."
    echo "Starting $TIME timer!"

    # Start time for PAUSE & RESUME
    SECONDS=0
    __TOMO_REMAINDER=TIME
    __TOMO_REPEAT=REPEAT
    
    sleep $TIME & wait $!
    notify-send "Break-time!" "Take $BREAK to relax" 
    sleep 2s
    xbacklight =1 -steps 10
    sleep $BREAK
    xbacklight =100 -steps 1
    xbacklight =1 -steps 1
    xbacklight =100 -steps 1 
    notify-send "Work-time!" "Try to concentrate for $TIME"
}

pause()
{
    # kill background jobs (timers)
    kill $(jobs -p)
    __TOMO_RESUME=true
    __TOMO_REMAINDER=$((__TOMO_REMAINDER-SECONDS))

    declare -p __TOMO_RESUME __TOMO_TIME __TOMO_REPEAT \
	    __TOMO_BREAK __TOMO_TASK > ./.e
    
    cat <<EOF 
Pausing current task... 
$SECONDS remain.
run $RESUME_SYNOPSIS to resume.

EOF
}

resume()
{
    echo "Resuming..."
    for((;__TOMO_REPEAT > 0; __TOMO_REPEAT--)); do
	run $__TOMO_TIME $__TOMO_BREAK $__TOMO_TASK
    done
}
