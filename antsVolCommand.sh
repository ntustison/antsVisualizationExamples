#!/bin/bash

INPUT_DIRECTORY=${PWD}/Images/
OUTPUT_DIRECTORY=${PWD}/OutputAntsVol/

mkdir -p $OUTPUT_DIRECTORY

INPUT_T1=${INPUT_DIRECTORY}/OAS1_0061_MR1_mpr_n4_anon_sbj_111.nii.gz
INPUT_SEGMENTATION=${INPUT_DIRECTORY}/OAS1_0061_MR1_mpr_n4_anon_sbj_111BrainSegmentation.nii.gz
INPUT_THICKNESS=${INPUT_DIRECTORY}/OAS1_0061_MR1_mpr_n4_anon_sbj_111CorticalThickness.nii.gz
INPUT_JLF=${INPUT_DIRECTORY}/OAS1_0061_MR1_mpr_n4_anon_sbj_111-refinedMalf.nii.gz

OUTPUT_GM=${OUTPUT_DIRECTORY}/grayMatterMask.nii.gz
OUTPUT_GM_SMOOTH=${OUTPUT_DIRECTORY}/grayMatterSmoothMask.nii.gz
OUTPUT_THICKNESS_RGB=${OUTPUT_DIRECTORY}/thicknessRgb.nii.gz
OUTPUT_LOOKUP_TABLE=${OUTPUT_DIRECTORY}/lookupTable.csv
OUTPUT_REGION=${OUTPUT_DIRECTORY}/regionMask.nii.gz
OUTPUT_REGION2=${OUTPUT_DIRECTORY}/regionMask2.nii.gz

OUTPUT_THICKNESS_PNG=${OUTPUT_DIRECTORY}/OAS1_0061_MR1_mpr_n4_anon_sbj_111CorticalThickness.png
OUTPUT_CAUDAL_THICKNESS_PNG=${OUTPUT_DIRECTORY}/OAS1_0061_MR1_mpr_n4_anon_sbj_111CorticalThickness2.png

echo "Thresholding out gray matter."
${ANTSPATH}/ThresholdImage 3 $INPUT_SEGMENTATION $OUTPUT_GM 2 4 1 0
echo "Filling the holes."
${ANTSPATH}/ImageMath 3 $OUTPUT_GM FillHoles $OUTPUT_GM
echo "Getting the largest component."
${ANTSPATH}/ImageMath 3 $OUTPUT_GM GetLargestComponent $OUTPUT_GM
echo "Smoothing the gray matter mask."
${ANTSPATH}/SmoothImage 3 $OUTPUT_GM 1.0 $OUTPUT_GM_SMOOTH
echo "Thresholding the smoothed gray matter mask."
${ANTSPATH}/ThresholdImage 3 $OUTPUT_GM_SMOOTH $OUTPUT_GM_SMOOTH 0.25 0.75 1 0

echo "Dilating the thickness image and converting to RGB."
${ANTSPATH}/ImageMath 3 $OUTPUT_THICKNESS_RGB GD $INPUT_THICKNESS 3
${ANTSPATH}/ConvertScalarImageToRGB 3 $OUTPUT_THICKNESS_RGB $OUTPUT_THICKNESS_RGB none hot none 0 8 0 255 ${OUTPUT_LOOKUP_TABLE}

echo "Show thickness over the entire brain"
${ANTSPATH}/antsVol -i [${OUTPUT_GM_SMOOTH},0.1x0.9] \
                    -d [1,0x0x0,0x0x0] \
                    -f ${OUTPUT_THICKNESS_RGB}


echo "Show thickness over the left and right caudal middle frontal (labels 1003 & 2003)"
${ANTSPATH}/ThresholdImage 3 $INPUT_JLF $OUTPUT_REGION 2003 2003 1 0
${ANTSPATH}/SmoothImage 3 $OUTPUT_REGION 1.0 $OUTPUT_REGION
${ANTSPATH}/ThresholdImage 3 $OUTPUT_REGION $OUTPUT_REGION 0.1 10 1 0

${ANTSPATH}/ThresholdImage 3 $INPUT_JLF $OUTPUT_REGION2 1003 1003 1 0
${ANTSPATH}/SmoothImage 3 $OUTPUT_REGION2 1.0 $OUTPUT_REGION2
${ANTSPATH}/ThresholdImage 3 $OUTPUT_REGION2 $OUTPUT_REGION2 0.1 10 1 0

${ANTSPATH}/antsVol -i [${OUTPUT_GM_SMOOTH},0.1x0.9] \
                    -d [1,0x0x0,0x0x0] \
                    -f [${OUTPUT_THICKNESS_RGB},${OUTPUT_REGION}] \
                    -f [${OUTPUT_THICKNESS_RGB},${OUTPUT_REGION2}] \

