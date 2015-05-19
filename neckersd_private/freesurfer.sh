#!/bin/bash

# get files which are 22MB (very strange names, but very consistent size for T1)
cd "/mnt/orange/romeijn/hdEEG fMRI Experiment/MRI data"
find . -size +10000k -size -50000k -exec du -h {} \;

# cp the data to freesurfer dir

cp "EK240708/Dag 2 RW/EK240708-2_T13D_5_1.PAR" /data1/projects/neckersd/recordings/vigd_freesurfer/raw/0001.PAR
cp "EK240708/Dag 2 RW/EK240708-2_T13D_5_1.REC" /data1/projects/neckersd/recordings/vigd_freesurfer/raw/0001.REC
cp "HE030608/dag1NR/hannah_NR1_T1_5_1.PAR" /data1/projects/neckersd/recordings/vigd_freesurfer/raw/0002.PAR
cp "HE030608/dag1NR/hannah_NR1_T1_5_1.REC" /data1/projects/neckersd/recordings/vigd_freesurfer/raw/0002.REC
cp MS190708/Dag\ 1\ RW/Mischa_Schirris_T13D_7_1.REC /data1/projects/neckersd/recordings/vigd_freesurfer/raw/0003.REC
cp MS190708/Dag\ 1\ RW/Mischa_Schirris_T13D_7_1.PAR /data1/projects/neckersd/recordings/vigd_freesurfer/raw/0003.PAR
cp MW200608/Dag\ 1\ RW/mw200608_4_1.PAR /data1/projects/neckersd/recordings/vigd_freesurfer/raw/0004.PAR
cp MW200608/Dag\ 1\ RW/mw200608_4_1.REC /data1/projects/neckersd/recordings/vigd_freesurfer/raw/0004.REC
cp NR090608/dag1SD/NicoRomeijn_SD1_5_1.PAR /data1/projects/neckersd/recordings/vigd_freesurfer/raw/0005.PAR
cp NR090608/dag1SD/NicoRomeijn_SD1_5_1.REC /data1/projects/neckersd/recordings/vigd_freesurfer/raw/0005.REC
cp RW290508/Dag\ 2\ RW/RW290508-2_5_1.PAR /data1/projects/neckersd/recordings/vigd_freesurfer/raw/0006.PAR
cp RW290508/Dag\ 2\ RW/RW290508-2_5_1.REC /data1/projects/neckersd/recordings/vigd_freesurfer/raw/0006.REC
cp TR280508/Dag\ 2\ SD/sd_30052008/thijs2sd_anat_4_1.PAR /data1/projects/neckersd/recordings/vigd_freesurfer/raw/0007.PAR
cp TR280508/Dag\ 2\ SD/sd_30052008/thijs2sd_anat_4_1.REC /data1/projects/neckersd/recordings/vigd_freesurfer/raw/0007.REC
cp WM191008/Dag\ 2\ RW/Willemijn_de_Mol_T13D_7_1.PAR  /data1/projects/neckersd/recordings/vigd_freesurfer/raw/0008.PAR
cp WM191008/Dag\ 2\ RW/Willemijn_de_Mol_T13D_7_1.REC  /data1/projects/neckersd/recordings/vigd_freesurfer/raw/0008.REC

