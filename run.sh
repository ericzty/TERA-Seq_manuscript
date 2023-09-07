#!/bin/bash
#
# Run script to install all dependencies, prepare all references and run all analyses
#
# You still have to make sure the sample directories are populated!
#

main_dir=$(dirname "$0") # Save location of this script to a variable

echo ">>> INSTALLING ADDITIONAL SOFTWARE <<<"
cd ${main_dir}/tools/
time ./run.sh &> log.out

echo ">>> COMPILING REFERENCES <<<"
cd ${main_dir}/tools
time ./run.sh &> log.out

#echo ">>> BASECALL FAST5 <<<"
# Note: You have to populate fast5 directories first if you want to re-basecall
#cd ${main_dir}/samples/
#time ./run_Guppy.sh

echo ">>> PREPARING SAMPLES <<<"
cd ${main_dir}/samples/
time ./run.sh &> log.out

echo ">>> RUNNING ADAPTER LENGTH VISUALIZATION <<<"
cd ${main_dir}/adapter/
time ./run.sh &> log.out

echo ">>> RUNNING ALIGNMENT STATISTICS <<<"
cd ${main_dir}/align-stats/
time ./run.sh &> log.out

echo ">>> RUNNING ANNOTATION CORRECTION AND META-COORDINATES <<<"
cd ${main_dir}/metacoord-correction/
time ./run.sh &> log.out

echo ">>> RUNNING CHANGES AFTER CORRECTION <<<"
cd ${main_dir}/reannot-change/
time ./run.sh &> log.out

echo ">>> RUNNING TRANSCRIPT COVERAGE <<<"
cd ${main_dir}/trans-coverage/
time ./run.sh &> log.out

echo ">>> RUNNING POLY(A) LENGTH <<<"
cd ${main_dir}/polya/
time ./run.sh &> log.out

echo ">>> RUNNING CAGE AND APA <<<"
cd ${main_dir}/cage_apa/
time ./run.sh &> log.out

echo ">>> RUNNING PROMOTER HEATMAP <<<"
cd ${main_dir}/promoter-heatmap/
time ./run.sh &> log.out

echo ">>> RUNNING RELATIVE POSITION DISTRIBUTION <<<"
cd ${main_dir}/relative-pos-distro/
time ./run.sh &> log.out

echo ">>> RUNNING CONSERVATION <<<"
cd ${main_dir}/conservation/
time ./run.sh &> log.out

echo ">>> RUNNING SIRV <<<"
cd ${main_dir}/sirv/
time ./run.sh &> log.out

echo ">>> RUNNING META-COORDINATES AND POLY(A) CORRELATION <<<"
cd ${main_dir}/metacoord-vs-polya/
time ./run.sh &> log.out

echo ">>> RUNNING EXPRESSION CORRELATION <<<"
cd ${main_dir}/expression/
time ./run.sh &> log.out

echo ">>> ALL DONE <<<"
