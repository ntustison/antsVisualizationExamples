#!/bin/bash

# Borrowed from https://github.com/stnava/antsSurf/blob/master/GenerateBrainMesh3.sh
# Showing:
#   1. Thickness
#   2.

INPUT_DIRECTORY=${PWD}/Images/
OUTPUT_DIRECTORY=${PWD}/OutputAntsSurf/

INPUT_T1=${INPUT_DIRECTORY}/OAS1_0061_MR1_mpr_n4_anon_sbj_111.nii.gz
INPUT_SEGMENTATION=${INPUT_DIRECTORY}/OAS1_0061_MR1_mpr_n4_anon_sbj_111BrainSegmentation.nii.gz
INPUT_THICKNESS=${INPUT_DIRECTORY}/OAS1_0061_MR1_mpr_n4_anon_sbj_111CorticalThickness.nii.gz

OUTPUT_GM=${OUTPUT_DIRECTORY}/grayMatterMask.nii.gz
OUTPUT_GM_SMOOTH=${OUTPUT_DIRECTORY}/grayMatterSmoothMask.nii.gz
OUTPUT_THICKNESS_RGB=${OUTPUT_DIRECTORY}/thicknessRgb.nii.gz
OUTPUT_LOOKUP_TABLE=${OUTPUT_DIRECTORY}/lookupTable.csv

${ANTSPATH}/ThresholdImage 3 $INPUT_SEGMENTATION $OUTPUT_GM 2 4 1 0
${ANTSPATH}/ImageMath 3 $OUTPUT_GM FillHoles $OUTPUT_GM
${ANTSPATH}/ImageMath 3 $OUTPUT_GM GetLargestComponent $OUTPUT_GM
${ANTSPATH}/SmoothImage 3 $OUTPUT_GM_SMOOTH 1.0 $OUTPUT_GM_SMOOTH
${ANTSPATH}/ThresholdImage 3 $OUTPUT_GM_SMOOTH $OUTPUT_GM_SMOOTH 0.1 1000 1 0

${ANTSPATH}/ImageMath 3 $OUTPUT_THICKNESS_RGB GD $INPUT_THICKNESS 2
${ANTSPATH}/ConvertScalarImageToRGB 3 $OUTPUT_THICKNESS_RGB $OUTPUT_THICKNESS_RGB hot none 0 8 0 255 ${OUTPUT_LOOKUP_TABLE}

${ANTSPATH}/antsSurf -d 3 \
                     -s [${OUTPUT_GM},192x255x62] \
                     -f [${OUTPUT_THICKNESS_RGB},${OUTPUT_GM_SMOOTH},0.5] \
                     -i 25 \
                     -a 0.05 \
                     -d 1






