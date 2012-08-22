#!/bin/bash

#mpc="mpc -h 192.168.10.14"
icons="/usr/share/icons/stlarch_icons"

function hc() {
    herbstclient "$@"
}

monitor=${1:-0}
geometry=( $(hc monitor_rect "$monitor") )
if [ -z "$geometry" ] ;then
    echo "Invalid monitor $monitor"
    exit 1
fi
# geometry has the format: WxH+X+Y
panel_width=${geometry[2]}
panel_height=16
x=${geometry[0]}
y=$((${geometry[3]} - ${geometry[1]} - $panel_height))
echo "x: $x, y: $y" >> /tmp/hlog
font="-*-fixed-medium-*-*-*-12-*-*-*-*-*-*-*"
bgcolor=$(hc get frame_border_normal_color)
selbg=$(hc get window_border_active_color)
selfg='#101010'

####
# Try to find textwidth binary.
# In e.g. Ubuntu, this is named dzen2-textwidth.
if [ -e "$(which textwidth 2> /dev/null)" ] ; then
    textwidth="textwidth";
elif [ -e "$(which dzen2-textwidth 2> /dev/null)" ] ; then
    textwidth="dzen2-textwidth";
else
    echo "This script requires the textwidth tool of the dzen2 project."
    exit 1
fi

function uniq_linebuffered() {
    awk '$0 != l { print ; l=$0 ; fflush(); }' "$@"
}

# Add a space for the panel at the bottom of the screen.
hc pad $monitor 0 0 $panel_height 0

{
    # events:
    # MPD
    if [[ $monitor -eq 1 ]]; then
        #$mpc idleloop player &
        # trigger an mpd event at the start
        echo "player"
    fi

    # Time
    while true ; do
        date +'date ^fg(#efefef)%H:%M:%S^fg(#909090), %Y-%m-^fg(#efefef)%d'
        sleep 1 || break
    done > >(uniq_linebuffered)  &
    childpid1=$!

    # Hearbeat
    while true ; do
        echo "heartbeat"
        sleep 1 || break
    done &

    # Herbsluftwm events
    hc --idle
    kill $childpid1 $childpid2
} 2>> /tmp/hlog | {
    TAGS=( $(hc tag_status $monitor) )
    date=""
    mpd_status=""
    windowtitle=""
    stats=""

    while true ; do
        bordercolor="#26221C"
        separator="^bg()^fg($selbg)|"
        # draw tags
        for i in "${TAGS[@]}" ; do
            case ${i:0:1} in
                '#')
                    # Tag is focused, and so is monitor
                    echo -n "^bg($selbg)^fg($selfg)"
                    ;;
                '+')
                    # Tag is focused, but monitor is not
                    echo -n "^bg(#9CA668)^fg(#141414)"
                    ;;
                ':')
                    # Tag is not focused, and is not empty
                    echo -n "^bg()^fg(#ffffff)"
                    ;;
                '!')
                    # The tag contains an urgent window
                    echo -n "^bg(#FF0675)^fg(#141414)"
                    ;;
                *)
                    # Otherwise
                    echo -n "^bg()^fg(#ababab)"
                    ;;
            esac
            # If tag is not empty, show it.
            if [[ "${i:0:1}" != '.' ]]; then
                #echo -n "^ca(1,herbstclient focus_monitor $monitor && herbstclient use ${i:1}) ${i:1} ^ca()"
                echo -n " ${i:1} "
            fi
        done
        echo -n "$separator"
        echo -n "^bg()^fg() ${windowtitle//^/^^}"
        # small adjustments
        right="$stats$mpd_status$date"
        right_text_only=$(echo -n "$right"|sed 's.\^[^(]*([^)]*)..g')
        # get width of right aligned text.. and add some space..
        width=$($textwidth "$font" "$right_text_only   ")
        echo -n "^pa($(($panel_width - $width)))$right"
        echo

        # wait for next event
        read line || break
        cmd=( $line )
        # find out event origin
        case "${cmd[0]}" in
            tag*)
                #echo "reseting tags" >&2
                TAGS=( $(hc tag_status $monitor) )
                ;;
            date)
                #echo "reseting date" >&2
                date="^fg()^i($icons/clock2.xbm) "
                date="${date}${cmd[@]:1}"
                ;;
            quit_panel)
                exit
                ;;
            reload)
                exit
                ;;
            focus_changed|window_title_changed)
                windowtitle="${cmd[@]:2}"
                ;;
            heartbeat)
                if [[ $monitor -eq 0 ]]; then
                    stats="$($HOME/bin/t) ${separator}"
                else
                    stats=""
                fi
                ;;
        esac
    done
} 2>> /tmp/hlog | dzen2 -w $panel_width -x $x -y $y -fn "$font" -h $panel_height \
    -ta l -bg "$bgcolor" -fg '#efefef' -e 2>&1 >> /tmp/hlog