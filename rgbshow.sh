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


do_showhelp() {
        echo "
Provide a one-line visualisation of 12bit hex colours
 
It also shows the equivalent greyscale (via linear approximation method)

Script tests each argument in turn. 
    * -h  = help
    * any three hex character string is displayed in colour
    * any other value is echoed to screen 

May be particularly useful when comparing a range of colours, eg 

    $0 817 a35 c66 e94 ed0 9d5 4d8 2cb 0bc 09c 36b 639 '12 bit rainbow palette from https://iamkate.com/data/12-bit-rainbow/'

results in:

$($0 817 a35 c66 e94 ed0 9d5 4d8 2cb 0bc 09c 36b 639 '12 bit rainbow palette from https://iamkate.com/data/12-bit-rainbow/')
"
}


# primary colours
REDBG=$(tput setab 196)
GRNBG=$(tput setab 46)
BLUBG=$(tput setab 21)

REDFG=$(tput setaf 196)
GRNFG=$(tput setaf 46)
BLUFG=$(tput setaf 21)

# secondary colours
AQUABG=$(tput setab 51)
MGNTBG=$(tput setab 201)
YLLOBG=$(tput setab 226)

AQUAFG=$(tput setaf 51)
MGNTFG=$(tput setaf 201)
YLLOFG=$(tput setaf 226)

# black and white
    # this isn't the pure black/white which is 0,15
    # but this is in the extended grid, so shouldn't be terminal configurable
BLACKBG=$(tput setab 232)
WHITEBG=$(tput setab 255)

# forcing black/white text 
BLACKFG=$(tput setaf 232)
WHITEFG=$(tput setaf 255)


SGR0=$(tput sgr0)

do_showrgb() {
    echo -n "  $SGR0#$R$G$B ["

    # we should never be travelling wider than about 60 characters anyway, so cub 100 gets us to the first column of the current line.
    # We're going to use this trick a fair bit, so while it doesn't NEED to be used here, it introduces it, and keeps it consistent with later numbers
    tput cub 100
    # 48 characters because we have 16 values, but have a three character block for each value
    # the 48 character block is from positions 8 to 55 

    # setting up our framing first, then filling in is less character efficient, but it's conceptually neat
    # and the inefficiency likely only relevant if you're on a VERY slow connection
    # (a bit shout out to everyone on 2400 baud in 2024)
    tput cuf 56
    echo -n "] " 

    REDPOS=$((0x$R * 3 + 8))
    GRNPOS=$((0x$G * 3 + 8))
    BLUPOS=$((0x$B * 3 + 8))

    # our main colours, in position (but visually as max R/G/B)
    tput cub 100 ; tput cuf $REDPOS
    printf "${REDBG}${WHITEFG}${R}__${SGR0}"

    tput cub 100 ; tput cuf $GRNPOS
    printf "${GRNBG}${BLACKFG}_${G}_${SGR0}"

    tput cub 100 ; tput cuf $BLUPOS
    printf "${BLUBG}${WHITEFG}__${B}${SGR0}"


    # did any of the above doubleup? if so, we replace the original with the relevant secondary colours here
    # * yes this is also inefficient by character use. hush. 

    [ $R == $G ] && tput cub 100 && tput cuf $REDPOS && printf "${YLLOBG}${BLACKFG}${R}${G}_${SGR0}"
    [ $R == $B ] && tput cub 100 && tput cuf $REDPOS && printf "${MGNTBG}${BLACKFG}${R}_${B}${SGR0}"
    [ $G == $B ] && tput cub 100 && tput cuf $GRNPOS && printf "${AQUABG}${BLACKFG}_${G}${B}${SGR0}"

    # and all the same = white bg in the relevant spot
    [ $R == $G ] && [ $G == $B ] && tput cub 100 && tput cuf $REDPOS && printf "${WHITEBG}${BLACKFG}${R}${G}${B}${SGR0}"


    # Let's show the seperate R/G/B channels visually now
    #
    # set our position: 
    tput cub 100 ; tput cuf 58

    printf ">"
    printf "\033[48;2;%d;%d;%dm" $((0x$R * 16)) 0 0
    printf "\033[38;2;%d;%d;%dm" $((0x$R * 16)) 0 0
    printf "R"
    printf "\033[48;2;%d;%d;%dm" 0 $((0x$G * 16)) 0
    printf "\033[38;2;%d;%d;%dm" 0 $((0x$G * 16)) 0
    printf "G"
    printf "\033[48;2;%d;%d;%dm" 0 0 $((0x$B * 16))
    printf "\033[38;2;%d;%d;%dm" 0 0 $((0x$B * 16)) 
    printf "B"

    printf "$SGR0< "


    # now we show the colour that was requested

    # print a four character block of our relevant colour
        # FG and BG identical, with '#RGB' within, as a hedge against one or the other not working
    printf "\033[48;2;%d;%d;%dm" $((0x$R$R)) $((0x$G$G)) $((0x$B$B))
    printf "\033[38;2;%d;%d;%dm" $((0x$R$R)) $((0x$G$G)) $((0x$B$B))
    printf "#$R$G$B$SGR0"

    # and in grey

    # grey=$(( ( 0x$R$R + 0x$G$G +  0x$B$B) /3 )) # simplistic average
    grey=$(( ( 0x$R$R * 299 + 0x$G$G * 587 +  0x$B$B * 114 )/1000 )) # linear approximation greyscale method
        # linear approx as per https://e2eml.school/convert_rgb_to_grayscale

    # set our grey colours
    printf "\033[48;2;%d;%d;%dm" $grey $grey $grey
    printf "\033[38;2;%d;%d;%dm" $grey $grey $grey
    printf "##$SGR0"   # Fill with # because grey colour may not be simple 12bit
    greyhex=$(printf '%x' $grey)
    printf " #%2s%2s%2s\n" $greyhex $greyhex $greyhex
}


while [ -n "$1" ] ; do
    
    if [ "${1}" == "-h" ] ; then
        do_showhelp
    elif [ ${#1} == 3 ] && [[ ${1} =~ ^[0-9A-Fa-f]{3}$ ]] ; then # we are a 3 digit hex value
        RGB=$1
        R=${RGB:0:1}
        G=${RGB:1:1}
        B=${RGB:2:1}
        do_showrgb $RGB
    else
        echo "$1"
    fi

    shift

done

