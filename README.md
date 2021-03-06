# NIGHTSHADE #

## POMODORO TECHNIQUE SCRIPT ##

Created by Jackson Cougar Wiebe on March 15, 2018

A linux-terminal script for running a pomodoro timer for the eponymous
management technique. 

The defining feature is the use of a visual cue by dimming of the screen to
signal when to take breaks, and restoring the screen when its time to return to
work. From personal experience with other pomodoro timers, sound or
notifications alone can be easily ignored. By introducing this visual cue that
physically hampers you from continuing the work without some effort it is easier
in my experience to switch into 'break mode'.

### SYNOPSIS ###

	tomato [COMMANDS] [TASK]

### DESCRIPTION ###

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

### EXAMPLE ###

![Example of normal work][work]
![Example of break notification][notify_break]
![Example of break][break]

Inspired by [this](https://github.com/rukshn/pomodoro).

## DEPENDANCIES ##

- Bash shell
- xdotool (linux)

## FEATURES ##

- Assign a task-name to the work timer
- Pause work timer.
- Log periods of work and completed tasks.
- Log breaks taken.

## PLANNED FEATURES ##

- nothing planned right now

[work]: https://github.com/jacksoncougar/Nightshade/blob/master/images/working.png
[notify_break]: https://github.com/jacksoncougar/Nightshade/blob/master/images/break_triggered.png
[break]: https://github.com/jacksoncougar/Nightshade/blob/master/images/break.png
