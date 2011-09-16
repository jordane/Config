#!/bin/bash
# Random wallpaper setter, by moljac024
#-------------------------------------------------------------------------------------
# Configuration

# Wallpaper directory
wpDir="$HOME/wallpapers"

# Wallpaper list path
wpList="$HOME/.wallpaper-list"

# Folders to be skipped, you can put as many as you like
#wpSkip=("Dir1/" "Dir2/")

# Scale images that have a lower resolution than that of the screen (yes or no)
scaleLowerRes="yes"
#scaleLowerRes="no"

# Screen resolution
resWidth=1920
resHeight=1200

# Command for tiling the wallpaper
cmdTile="feh --bg-tile"
#cmdTile="nitrogen --set-tiled --save"OA
#cmdTile="xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/image-style -s 2 && xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/image-path -s"
#cmdTile="gconftool-2 -t str --set /desktop/gnome/background/picture_options "wallpaper" -t str --set /desktop/gnome/background/picture_filename"

# Command for scaling the wallpaper
cmdScale="feh --bg-scale"
#cmdScale="nitrogen --set-scaled --save"
#cmdScale="xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/image-style -s 3 && xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/image-path -s"
#cmdScale="gconftool-2 -t str --set /desktop/gnome/background/picture_options "zoom" -t str --set /desktop/gnome/background/picture_filename"

# Command for centering the wallpaper
cmdCenter="feh --bg-center"
#cmdCenter="nitrogen --set-centered --save"
#cmdCenter="xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/image-style -s 1 && xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/image-path -s"
#cmdCenter="gconftool-2 -t str --set /desktop/gnome/background/picture_options "centered" -t str --set /desktop/gnome/background/picture_filename"

# End of configuration
#-------------------------------------------------------------------------------------

setTiled ()
{
`$cmdTile "$1"`
if [ "$?" = "0" ]; then
echo "Wallpaper tiled."
else
echo "Wallpaper not set!"
exit 1
fi
}

setScaled ()
{
`$cmdScale "$1"`
if [ "$?" = "0" ]; then
echo "Wallpaper scaled."
else
echo "Wallpaper not set!"
exit 1
fi
}

setCentered ()
{
`$cmdCenter "$1"`
if [ "$?" = "0" ]; then
echo "Wallpaper centered."
else
echo "Wallpaper not set!"
exit 1
fi
}

createList ()
{
# Go to the wallpaper directory
cd "$wpDir"

# Load the list of pictures to a variable
wpDirList=`(find . -regex ".*\([jJ][pP][gG]\|[jJ][pP][eE][gG]\|[gG][iI][fF]\|[pP][nN][gG]\|[bB][mM][pP]\)$"  -type f)`

# Save the list to disk
if [[ ( -w "$wpList" ) ]]; then
echo -n "$wpDirList" > "$wpList"
# Filter out unwanted folders
if [[ "$dontSkip" == "false" ]]; then
for dir in "${wpSkip[@]}" 
do
   grep -Ev "$dir" "$wpList" > ~/.wallpapers-tmpr; mv ~/.wallpapers-tmpr "$wpList"
done
fi
# Output result
echo "Wallpaper list saved."
else
echo "Can't write wallpaper list, aborting!"
exit 1
fi
}

getImage ()
{
# Count number of pictures in the wallpaper list by counting number of lines.
# Check if the wallpaper list exists, is not empty and we have read persmission on it
if [[ ( -s "$wpList" && -f "$wpList" ) && -r "$wpList" ]]
    then
    wpListNumber=$(wc -l < "$wpList")
    else
    echo "Can't read wallpaper list, aborting!";
    exit 1
fi

# Counter for bad entries in wallpaper list
badMax=100

while true; do

# Get a seed for the random number generator from /dev/urandom
SEED=$(head -1 /dev/urandom | od -N 1 | awk '{ print $2 }')
RANDOM=$SEED

# Find a random line number in the wallpaper list
# Random number from 1..n.
#r=$((RANDOM % $wpListNumber + 1))
r=$(echo $RANDOM%"$wpListNumber"+1 | bc)

# Print what the line number is
# Print the r'th line.
imgPath=`sed -n "$r{p;q;}" "$wpList"`
# #./ crops that substring but it doesn't matter if it left there
wpPath="${wpDir}${imgPath#./}"

# Check if the chosen file exists
if [ -f "$wpPath" ]; then
    break
else
    echo -e ""$wpPath": doesn't exist!\n"
    badMax=$(( $badMax - 1 ))
    if [ "$badMax" == "0" ]; then
    echo "Too many non-valid entries found in wallpaper list, aborting!"
    exit 1
        else echo "Choosing new image..."
    fi
continue
fi
done

# Calculate size and aspect for chosen image and print out information
imgHeight=$(identify -format "%h" "$wpPath")
imgWidth=$(identify -format "%w" "$wpPath")
imgAspect=$(echo "scale=1; "$imgWidth"/"$imgHeight"" | bc)
echo -e "Image: "$wpPath"\n"
echo -e "Resolution: "$imgWidth"x"$imgHeight""
echo -e "Aspect: "$imgAspect":1\n"
}

setWallpaper ()
{
# Calculate resolution aspect ratio
resAspect=$(echo "scale=1; "$resWidth"/"$resHeight"" | bc)

# If the image is smaller than the resolution and is not a tile then scale it, otherwise look at aspect
if [[ ("$scaleLowerRes" == "yes") && ( "$imgAspect" != "1.0" && ("$imgWidth" -lt "$resWidth" || "$imgHeight" -lt "$resHeight") ) ]]
then
setScaled "$wpPath"
else
case $imgAspect in
1.0)
setTiled "$wpPath"
;;
1.5 | 1.6 | 1.7 | 1.8)
if [[ "$resAspect" < "1.5" ]]; then
setCentered "$wpPath"
else
setScaled "$wpPath"
fi
;;
*)
if [[ "$resAspect" < "1.5" ]]; then
setScaled "$wpPath"
else
setCentered "$wpPath"
fi
;;
esac
fi
}

checkConfig ()
{
# Initial errors
errorsPresent="no"
dontSkip="false"
# Check if all variables are set
if [[ !( ( -n "$wpDir" ) && ( -n "$wpList" ) && ( -n "$resWidth" ) && ( -n "$resHeight" ) && ( -n "$scaleLowerRes" ) && ( -n "$cmdTile" ) && ( -n "$cmdScale" ) && ( -n "$cmdCenter" ) ) ]]
then
echo -e "\nOne or more options not set, aborting!"
exit 1
fi

# Check if there is a trailing backslash in the wallpaper directory
spDir=`echo -n "$wpDir" | tail -c -1`
if [[ !( "$spDir" == "/" ) ]]
then
wpDir=""$wpDir"/"
fi

# Check if there is read permission on wallpaper directory and if it is a directory
if [[ !( ( -r "$wpDir" ) && ( -d "$wpDir" ) ) ]]
then
echo "Can't read wallpaper directory!"
errorsPresent="yes"
fi

# Check if the specified wallpaper list is a regular file and not a directory
touch "$wpList" &> /dev/null
if [[ ( -d "$wpList" ) ]]
then
echo "Specified wallpaper list is a directory, not a file!"
errorsPresent="yes"
fi

# Check if variables are set correctly
if [[ !( "$scaleLowerRes" == "yes" || "$scaleLowerRes"  == "no" ) ]]
then
echo "Specified option for scaling the wallpaper is not valid!"
errorsPresent="yes"
fi

if $(echo ""$resWidth"" | grep [^0-9] &>/dev/null)
then
echo "Specified resolution width is not a number!"
errorsPresent="yes"
fi

if $(echo ""$resHeight"" | grep [^0-9] &>/dev/null)
then
echo "Specified resolution height is not a number!"
errorsPresent="yes"
fi

# Check if any of the tests failed
if [[ "$errorsPresent" == "yes" ]]
then
echo -e "\nOne or more errors found, aborting!"
exit 1
fi
}

ignoreWPSkip()
{
dontSkip="true"
}

printUsage ()
{
echo -e "Invalid command line argument(s)!\nUsage:\n"
echo -e "`basename "$0"` [options]\n"
echo -e "Options:\n"
echo -e "-s  | --set       \tSet a wallpaper without updating the list"
echo -e "-u  | --update    \tUpdate the list without setting a wallpaper"
echo -e "-ua | --update-all\tUpdate the list without setting a wallpaper, but don't skip any folders"
echo -e "-su | --set-update\tUpdate the list and set a wallpaper"
exit 1
}

if [ "$#" == "1" ]; then
case "$1" in
"-s" | "--set")
checkConfig
getImage
setWallpaper
exit 0
;;
"-u" | "--update")
checkConfig
createList
exit 0
;;
"-ua" | "--update-all")
checkConfig
ignoreWPSkip
createList
exit 0
;;
"-su" | "--set-update")
checkConfig
createList
getImage
setWallpaper
exit 0
;;
*)
printUsage
exit 1
;;
esac
else
printUsage
exit 1
fi
