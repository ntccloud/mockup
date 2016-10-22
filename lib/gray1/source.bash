# source image https://unsplash.com/@firmbee?photo=GANqCr1BRTU

# setup defaults
SRC1=${SRCS[0]};
SRC2=${SRCS[0]};

# update defaults if possible
if [ -n "${SRCS[1]}" ]; then SRC2=${SRCS[1]}; fi

# image size
IW=4133;
IH=2745;

# first image coordiantes
AX1=1392;
AY1=976;

BX1=2760;
BY1=2286;

CX1=2344;
CY1=471;

DX1=3738;
DY1=1533;

# second image coordiantes
# additionally, deviation for the second image
DEX=500; # push 500 pixels to the right
DEY=50; # push 50 pixels to the bottom

AX2=$(($AX1+$DEX));
AY2=$(($AY1+$DEY));

BX2=$(($BX1+$DEX));
BY2=$(($BY1+$DEY));

CX2=$(($CX1+$DEX));
CY2=$(($CY1+$DEY));

DX2=$(($DX1+$DEX));
DY2=$(($DY1+$DEY));

# create a blank canvas
convert -size ${IW}x${IH}^ canvas:'#333333' "${DIR}/lib/${SUB}/layer-00.png";

# prepare image layers
convert -size ${IW}x${IH}^ canvas:transparent "${DIR}/lib/${SUB}/layer-01.png";
convert -size ${IW}x${IH}^ canvas:transparent "${DIR}/lib/${SUB}/layer-02.png";

# get the width and then height of the hole (based on the four hole coordinates)
# first image
HW1=$(echo "scale=2;sqrt(((${CX1}-${AX1})^2)+((${CY1}-${AY1})^2))"|bc)
HH1=$(echo "scale=2;sqrt(((${BX1}-${AX1})^2)+((${BY1}-${AY1})^2))"|bc)
# second image
HW2=$(echo "scale=2;sqrt(((${CX2}-${AX2})^2)+((${CY2}-${AY2})^2))"|bc)
HH2=$(echo "scale=2;sqrt(((${BX2}-${AX2})^2)+((${BY2}-${AY2})^2))"|bc)

# resize SRC image to match the artwork hole.
convert "${SRC1}" -resize ${HW1}x${HH1}^ -gravity center -crop ${HW1}x${HH1}+0+0 -sharpen 0x2 -quality 100 "${DIR}/lib/${SUB}/resized1.png";
convert "${SRC2}" -resize ${HW2}x${HH2}^ -gravity center -crop ${HW2}x${HH2}+0+0 -sharpen 0x2 -quality 100 "${DIR}/lib/${SUB}/resized2.png";

convert "${DIR}/lib/${SUB}/resized1.png" \( +clone -background black -shadow 80x10-55+55 \) +swap -background none  -layers merge +repage "${DIR}/lib/${SUB}/resized1.png"
convert "${DIR}/lib/${SUB}/resized2.png" \( +clone -background black -shadow 80x10-55+55 \) +swap -background none  -layers merge +repage "${DIR}/lib/${SUB}/resized2.png"

# insert resized1 SRC image into blank canvas;
composite -geometry +0+0 "${DIR}/lib/${SUB}/resized1.png" "${DIR}/lib/${SUB}/layer-01.png" "${DIR}/lib/${SUB}/layer-01.png";
rm "${DIR}/lib/${SUB}/resized1.png";
# four point distort of the SRC image recently placed on blank canvas, to fit into the upcoming artwork hole
convert "${DIR}/lib/${SUB}/layer-01.png" -matte -virtual-pixel transparent -distort Perspective "0,0,${AX1},${AY1} 0,${HH1},${BX1},${BY1} ${HW1},0,${CX1},${CY1} ${HW1},${HH1},${DX1},${DY1}" "${DIR}/lib/${SUB}/layer-01.png";

# insert resized2 SRC image into blank canvas;
composite -geometry +0+0 "${DIR}/lib/${SUB}/resized2.png" "${DIR}/lib/${SUB}/layer-02.png" "${DIR}/lib/${SUB}/layer-02.png";
rm "${DIR}/lib/${SUB}/resized2.png";
# four point distort of the SRC image recently placed on blank canvas, to fit into the upcoming artwork hole
convert "${DIR}/lib/${SUB}/layer-02.png" -matte -virtual-pixel transparent -distort Perspective "0,0,${AX2},${AY2} 0,${HH2},${BX2},${BY2} ${HW2},0,${CX2},${CY2} ${HW2},${HH2},${DX2},${DY2}" "${DIR}/lib/${SUB}/layer-02.png";


# place artwork layer over the resized/distorted SRC image and save result
composite -geometry +0+0 "${DIR}/lib/${SUB}/layer-02.png" "${DIR}/lib/${SUB}/layer-00.png" "${DIR}/lib/${SUB}/layer-00.png";
composite -geometry +0+0 "${DIR}/lib/${SUB}/layer-01.png" "${DIR}/lib/${SUB}/layer-00.png" "${OUT}";
rm "${DIR}/lib/${SUB}/layer-00.png";
rm "${DIR}/lib/${SUB}/layer-01.png";
rm "${DIR}/lib/${SUB}/layer-02.png";
