#!/usr/bin/bash
# This script used to send signals to Deadd notification center.
#
# This script is using `notif-send.py` under the hood, make sure it is
# installed.

start_cmd="deadd-notification-center"
process_name="deadd-notificat"
about="Deadd control script - send signals to Deadd notification center"

# check dependencies
if ! command -v notify-send.py &>/dev/null; then
	echo "Please install notify-send.py"
	exit 1
fi

# shellcheck disable=SC2317
start() {
	# check if service already active
	status && return 1
	# start the service
	exec $start_cmd &>/dev/null &
	# disown the process
	disown
}

# shellcheck disable=SC2317
status() {
	pgrep "$process_name" &>/dev/null
}

# shellcheck disable=SC2317
stop() {
	pkill "$process_name"
}

# shellcheck disable=SC2317
toggle() {
	pkill -USR1 "$process_name"
}

# shellcheck disable=SC2317
reload_css() {
	notify-send.py Reloaded --hint boolean:deadd-notification-center:true string:type:reloadStyle
}

# shellcheck disable=SC2317
restart() {
	stop
	start
}

# shellcheck disable=SC2317
pause() {
	notify-send.py a --hint boolean:deadd-notification-center:true string:type:pausePopups
}

# shellcheck disable=SC2317
resume() {
	notify-send.py a --hint boolean:deadd-notification-center:true string:type:unpausePopups
}

# shellcheck disable=SC2317
cnotifications() {
	notify-send.py a --hint boolean:deadd-notification-center:true string:type:clearInCenter
}

# shellcheck disable=SC2317
cpopups() {
	notify-send.py a --hint boolean:deadd-notification-center:true string:type:clearPopups
}

# shellcheck disable=SC2317
high() {
	if [ -z "$1" ]; then
		echo "Please provide the id of the action button, e.g. 1"
		exit 1
	fi
	notify-send.py a --hint boolean:deadd-notification-center:true int:id:"$1" \
		boolean:state:true type:string:buttons
}

# shellcheck disable=SC2317
low() {
	if [ -z "$1" ]; then
		echo "Please provide the id of the action button, e.g. 1"
		exit 1
	fi
	notify-send.py a --hint boolean:deadd-notification-center:true int:id:"$1" \
		boolean:state:false type:string:buttons
}

# shellcheck disable=SC2317
ping() {
	notify-send.py "Deadd Control Script" "Pong" \
		--hint boolean:action-icons:true \
		string:image-path:face-cool \
		int:has-percentage:33 \
		--action yes:face-smile no:face-sad
}

# shellcheck disable=SC2317
ping_normal() {
	notify-send.py "Deadd Control Script" "Normal Pong"
}

# shellcheck disable=SC2317
ping_silent() {
	notify-send.py "Deadd Control Script" "Silent Pong" -t 1
}

# shellcheck disable=SC2317
ping_critical() {
	notify-send.py "Deadd Control Script" "Critical Pong" -u critical
}

# shellcheck disable=SC2317
ping_low() {
	notify-send.py "Deadd Control Script" "Low Pong" -u low
}

# shellcheck disable=SC2317
ping_slider() {
	notify-send.py "This notification has a slider" "33%" \
		--hint int:has-percentage:33 \
		--action changeValue:abc
}

# main script
# shellcheck disable=SC2317
help() {
	echo -e "$about\n\n"
	echo "Commands:"

	for cmd in "${!commands[@]}"; do
		echo -e "\t$cmd:\n\t\t${commands[$cmd]}\n"
	done
}

usage() {
	local IFS="|"
	echo "Usage: deadd_control.sh <${!commands[*]}>"
	exit 1
}

# define the commands help messages
declare -A commands=(
	["start"]="Starts the service if not already started!"
	["stop"]="Stops the service if already started!"
	["status"]="Checks if the service is already running"
	["toggle"]="Toggles show/hide state of the notification center"
	["pause"]="Pauses the popup notifications (do not disturb mode)"
	["resume"]="Resumes the popup notifications"
	["cnotifications"]="Clears all the notifications"
	["cpopups"]="Clears all the popped-up notifications"
	["reload_css"]="Reloads css styles"
	["restart"]="Restarts the service"
	["high"]="Sets the state of action button by its id to high"
	["low"]="Sets the state of action button by its id to low"
	["ping"]="Send a ping notification for testing"
	["ping_normal"]="Send a normal notification for testing"
	["ping_silent"]="Send a silent notification for testing"
	["ping_critical"]="Send a critical ping notification for testing"
	["ping_low"]="Send a low ping notification for testing"
	["ping_slider"]="Send a ping notification with a slider for testing"
	["help"]="Shows this message"
)

# loop through the commands and execute the matched one
for cmd in "${!commands[@]}"; do
	[ "$1" != "$cmd" ] && continue
	shift
	eval "$cmd $*"
	exit $?
done

# if no any commands matched then show the usage
usage
