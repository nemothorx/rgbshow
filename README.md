# RGB show - Provide a one-line visualisation of a 12bit hex colour
 
Designed for 24bit capable colour terminals, this will show on a single line the following for each colour given 

* the R/G/B values relative to each other linearly along the X axis
* The R/G/B colours as seperate channels
* A colour swatch
* A swatch (anmd 32bit RGB code) of the greyscale equivalent
  * Greyscale via linear approximation method: https://e2eml.school/convert_rgb_to_grayscale

Valid options are: 

* "-h" - will show the help 
* abc  - any three character hex string will get shown as described above
* "any other string" - will be simply echoed literally. 
  * eg `rgbshow.sh "Hello world" 817 a35 c66 e94 ed0 9d5 4d8 2cb 0bc 09c 36b 639`

![2024-10-02T13:16:04_0535ca33](https://github.com/user-attachments/assets/212f9381-943c-4355-8a6c-fdb25b1bc851)

(example rainbow taken from [The 12-bit rainbow palette](https://iamkate.com/data/12-bit-rainbow/))
