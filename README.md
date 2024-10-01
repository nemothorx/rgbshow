# RGB show - Provide a one-line visualisation of a 12bit hex colour
 
Designed for 24bit capable colour terminals, this will show on a single line the following: 

* the R/G/B values relative to each other linearly along the X axis
* The R/G/B colours as seperate channels
* A colour swatch
* A swatch (anmd 32bit RGB code) of the greyscale equivalent
  * Greyscale via linear approximation method: https://e2eml.school/convert_rgb_to_grayscale

Note that the script operates on a single 3 hex character RGB string as $1 ONLY (ie, three character shorthand hexidecimal like 'E94'). 

A shell loop is an easy way to see a range of colours: 

    for rgb in 817 a35 c66 e94 ed0 9d5 4d8 2cb 0bc 09c 36b 639 ; do 
        rgbshow.sh $rgb
    done

(That example rainbow taken from [The 12-bit rainbow palette](https://iamkate.com/data/12-bit-rainbow/))
