#!/bin/bash

# Given a 12 bit RGB value on the commandline (eg #0F8), represent it visually
#
# 0F8 [ 0__,,,...,,,...,,,...,,,__8,,,...,,,...,,,..._F_ ] XXX YYY
# where "." and "," would be blank, they are there only to show spacing
# 0__ __8 and _F_ would be inverted pure red/green/blue, since the intention is not to show (eg) 008 in blue, but where blue sits at value 008. 
# If two or three values, overlap, then show suitably. eg, FF_ would be in yellow
# [ and ] would be framing
# XXX is the final colour correctly shown
# YYY would be, if I can calculate it, the greyscale version of it

if [ $1 == "-h" ] ; then
    echo "
Provide a one-line visualisation of a 12bit hex colour
 (ie, three character shorthand hexidecimal like '0F8'

It also shows the equivalent greyscale, via simplistic (R+B+G)/3 average

Particularly useful when comparing a range of colours, eg 
for rgb in 817 a35 c66 e94 ed0 9d5 4d8 2cb 0bc 09c 36b 639 ; do $0 \$rgb ; done
"
    # that example palette is from https://iamkate.com/data/12-bit-rainbow/

    exit 0
fi



[ "${#1}" -ne 3 ] && echo "! I accept a 3 hex RGB string as \$1 ONLY" && exit 1

# primary colours
REDBG=$(tput setab 196)
GRNBG=$(tput setab 46)
BLUBG=$(tput setab 21)

# secondary colours
AQUABG=$(tput setab 51)
MGNTBG=$(tput setab 201)
YLLOBG=$(tput setab 226)

# black and white
    # this isn't the pure black/white which is 0,15
    # but this is in the extended grid, so shouldn't be terminal configurable
BLACKBG=$(tput setab 232)
WHITEBG=$(tput setab 255)

# forcing black/white text 
BLACKFG=$(tput setaf 232)
WHITEFG=$(tput setaf 255)


SGR0=$(tput sgr0)

RGB=$1

R=${RGB:0:1}
G=${RGB:1:1}
B=${RGB:2:1}

echo -n "    $SGR0#$R$G$B ["

# we should never be travelling wider than about 60 characters anyway, so cub 100 gets us to the first column of the current line.
# We're going to use this trick a fair bit, so while it doesn't NEED to be used here, it introduces it, and keeps it consistent with later numbers
tput cub 100
# 48 characters because we have 16 values, but have a three character block for each value
# the 48 character block is from positions 10 to 57 (nice and easy relative to expected 0-47 yeah?)

# setting up our framing first, then filling in is less character efficient, but it's conceptually neat
# and the inefficiency likely only relevant if you're on a VERY slow connection
# (a bit shout out to everyone on 2400 baud in 2024)
tput cuf 58 

echo -n "] " 

REDPOS=$((0x$R * 3 + 10))
GRNPOS=$((0x$G * 3 + 10))
BLUPOS=$((0x$B * 3 + 10))

# our main colours, in position
tput cub 100 ; tput cuf $REDPOS
printf "${REDBG}${R}__${SGR0}"

tput cub 100 ; tput cuf $GRNPOS
printf "${GRNBG}_${G}_${SGR0}"

tput cub 100 ; tput cuf $BLUPOS
printf "${BLUBG}__${B}${SGR0}"


# did any of the above doubleup? if so, we replace the original with the relevant secondary colours here
# * they get black text
# * yes this is also inefficient by character use. hush. 

[ $R == $G ] && tput cub 100 && tput cuf $REDPOS && printf "${YLLOBG}${BLACKFG}${R}${G}_${SGR0}"
[ $R == $B ] && tput cub 100 && tput cuf $REDPOS && printf "${MGNTBG}${BLACKFG}${R}_${B}${SGR0}"
[ $G == $B ] && tput cub 100 && tput cuf $GRNPOS && printf "${AQUABG}${BLACKFG}_${G}${B}${SGR0}"

# and all the same = black text on white bg in the relevant spot
[ $R == $G ] && [ $G == $B ] && tput cub 100 && tput cuf $REDPOS && printf "${WHITEBG}${BLACKFG}${R}${G}${B}${SGR0}"


# now we show the colour that was requested

# set our position: 
tput cub 100 ; tput cuf 60

# print a four character block of our relevant colour
    # FG and BG identical, with '#RGB' within, as a hedge against one or the other not working
printf "\033[48;2;%d;%d;%dm" $((0x$R * 16)) $((0x$G * 16)) $((0x$B * 16))
printf "\033[38;2;%d;%d;%dm" $((0x$R * 16)) $((0x$G * 16)) $((0x$B * 16))
printf "#$R$G$B$SGR0"

# and in grey

grey=$(( ( 0x$R * 16 + 0x$G * 16 +  0x$B * 16) /3 )) # simplistic average
# set our grey colours
printf "\033[48;2;%d;%d;%dm" $grey $grey $grey
printf "\033[38;2;%d;%d;%dm" $grey $grey $grey
printf "####$SGR0"   # Fill with # because grey colour may not be simple 12bit
greyhex=$(printf '%x' $grey)
printf " #%2s%2s%2s" $greyhex $greyhex $greyhex

echo
