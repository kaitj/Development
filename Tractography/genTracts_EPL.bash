#!/bin/bash

if [ "$#" -lt 1 ]
then
 echo "Usage $0 <subjid/list>"
 exit 0
fi

if [ -f $1 ]
then
 subjids=`cat $1`
else
 subjids=$1
fi 

CAMINO_HEAP_SIZE=16000

work_dir=~/EpilepsyDatabase/EPL14B
out_dir=.

for subj in $subjids
do

subj_dir=$work_dir/$subj
dwi=$subj_dir/dwi/multiband_topup_eddy/dwi.nii.gz
bval=$subj_dir/dwi/multiband_topup_eddy/dwi.bval
bvec=$subj_dir/dwi/multiband_topup_eddy/dwi.bvec
mask=$subj_dir/dwi/multiband_topup_eddy/dwi_brain_mask.nii.gz

scheme=$out_dir/$subj/Output/dwi.scheme
bfloat=$out_dir/$subj/Output/dwi.Bfloat
bdouble=$out_dir/$subj/Output/dwi.Bdouble
wm_mask=$out_dir/$subj/Output/wm_mask.nii.gz
wm_tract=$out_dir/$subj/Output/wmTracts.Bfloat
wm_vtk=$out_dir/$subj/Output/wmTracts.vtk

# Create scheme file 
echo fsl2scheme -bvecs $bvec -bvals $bval -bscale 1 -outputfile $scheme
fsl2scheme -bvecs $bvec -bvals $bval -bscale 1 -outputfile $scheme

# Convert data
echo image2voxel -4dimage $dwi -outputfile $bfloat
image2voxel =4dimage $dwi -outputfile $bfloat

# Fit tensor
echo modelfit -inputfile $bfloat -schemefile $scheme -bgmask $mask -outputfile $bdouble
modelfit -inputfile $bfloat -schemefile $scheme -bgmask $mask -outputfile $bdouble

echo voxel2image -outputroot $out_dir/$subj/Output/fa -header $dwi
cat $bdouble | fa | voxel2image -outputroot $out_dir/$subj/Output/fa -header $dwi

# Create WM mask
echo fslmaths $out_dir/$subj/Output/fa.nii.gz -thr 0.15 -uthr 1.0 $wm_mask
fslmaths $out_dir/$subj/Output/fa.nii.gz -thr 0.15 -uthr 1.0 $wm_mask    

echo track -inputmodel dt -inputfile $bfloat -schemefile $scheme -seedfile $wm_mask -anisthresh 0.15 -curvethresh 70 -outputfile $wm_Tract
track -inputmodel dt =inputfile $bfloat -schemefile $scheme -seedfile $wm_mask -anisthresh 0.15 -curvethresh 70 -outputfile $wm_Tract

echo vtkstreamlines -colourorient < $wm_tract > $wm_vtk
vtkstreamlines -colourorient < $wm_tract > $wm_vtk

done #subj
