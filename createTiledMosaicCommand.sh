#!/bin/bash

INPUT_DIRECTORY=${PWD}/Images/
OUTPUT_DIRECTORY=${PWD}/OutputCreateTiledMosaic/

mkdir -p $OUTPUT_DIRECTORY

INPUT_T1=${INPUT_DIRECTORY}/OAS1_0061_MR1_mpr_n4_anon_sbj_111.nii.gz
INPUT_SEGMENTATION=${INPUT_DIRECTORY}/OAS1_0061_MR1_mpr_n4_anon_sbj_111BrainSegmentation.nii.gz
INPUT_THICKNESS=${INPUT_DIRECTORY}/OAS1_0061_MR1_mpr_n4_anon_sbj_111CorticalThickness.nii.gz
INPUT_JLF=${INPUT_DIRECTORY}/OAS1_0061_MR1_mpr_n4_anon_sbj_111-refinedMalf.nii.gz

OUTPUT_THICKNESS_MOSAIC=${OUTPUT_DIRECTORY}/thicknessMosaic.png
OUTPUT_THICKNESS_RGB=${OUTPUT_DIRECTORY}/thicknessRgb.nii.gz
OUTPUT_THICKNESS_MASK=${OUTPUT_DIRECTORY}/thicknessMask.nii.gz

OUTPUT_SEGMENTATION_MOSAIC=${OUTPUT_DIRECTORY}/segmentationMosaic.png
OUTPUT_SEGMENTATION_RGB=${OUTPUT_DIRECTORY}/segmentationRgb.nii.gz
OUTPUT_SEGMENTATION_MASK=${OUTPUT_DIRECTORY}/segmentationMask.nii.gz

ITKSNAP_COLORMAP=${OUTPUT_DIRECTORY}/snapColormap.txt

echo "Making thickness mask."
${ANTSPATH}/ThresholdImage 3 ${INPUT_THICKNESS} ${OUTPUT_THICKNESS_MASK} 0 0 0 1
echo "Converting thickness to RGB."
${ANTSPATH}/ConvertScalarImageToRGB 3 $INPUT_THICKNESS $OUTPUT_THICKNESS_RGB none hot none 0 8 0 255

echo "Making thickness mosaic."
${ANTSPATH}/CreateTiledMosaic -i ${INPUT_T1} \
                              -r ${OUTPUT_THICKNESS_RGB} \
                              -o ${OUTPUT_THICKNESS_MOSAIC} \
                              -a 1.0 \
                              -t -1x-1 \
                              -d 2 \
                              -p mask \
                              -s [3,mask,mask] \
                              -x ${OUTPUT_THICKNESS_MASK}

echo "0 1 0 0 1 0 1" > $ITKSNAP_COLORMAP
echo "0 0 1 0 1 1 0" >> $ITKSNAP_COLORMAP
echo "0 0 0 1 0 1 1" >> $ITKSNAP_COLORMAP

echo "Making segmentation mask."
${ANTSPATH}/ThresholdImage 3 ${INPUT_SEGMENTATION} ${OUTPUT_SEGMENTATION_MASK} 0 0 0 1
echo "Converting thickness to RGB."
${ANTSPATH}/ConvertScalarImageToRGB 3 ${INPUT_SEGMENTATION} ${OUTPUT_SEGMENTATION_RGB} none custom $ITKSNAP_COLORMAP 0 6

echo "Making segmentation mosaic."
${ANTSPATH}/CreateTiledMosaic -i ${INPUT_T1} \
                              -r ${OUTPUT_SEGMENTATION_RGB} \
                              -o ${OUTPUT_SEGMENTATION_MOSAIC} \
                              -a 0.3 \
                              -t -1x-1 \
                              -d 2 \
                              -p mask \
                              -s [3,mask,mask] \
                              -x ${OUTPUT_SEGMENTATION_MASK}
