#!/bin/bash

# Firstly:
# manually download bzip2-1.0.6 from soundforge website:
# https://sourceforge.net/projects/bzip2/files/latest/download
# It should now be in the downloads folder.

# To run this script, type following 2 lines into command line:
# cd /home/pi/Desktop/Bioacoustics
# bash install_R_auto_script.sh

RED='\033[0;31m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

printf "${GREEN}Here we go ..... Fingers crossed! ${NC}\n"

sudo apt-get update
sudo apt-get upgrade -y

printf "${GREEN}Update and upgrade done! ${NC}\n"

# If necessary, check the version of bzip is as below:
cd && cd /home/pi/Downloads/
tar zxvf bzip2-1.0.6.tar.gz 
cd bzip2-1.0.6
sudo make install

printf "${GREEN}bzip2 installed! ${NC}\n"

sudo apt-get install liblzma-dev
sudo apt-get install cmake -y

sudo apt-get install -y gfortran libreadline6-dev libx11-dev libxt-dev libpng-dev libjpeg-dev libcairo2-dev xvfb libcurl4-openssl-dev texinfo

printf "${GREEN}Start to install R! ${NC}\n"

cd /home/pi/
mkdir R_HOME
cd R_HOME
wget http://cran.rstudio.com/src/base/R-3/R-3.6.1.tar.gz
tar zxvf R-3.6.1.tar.gz 
cd && cd R_HOME/R-3.6.1/
./configure --enable-R-shlib #--with-blas --with-lapack #optional
make
sudo make install

R --version

printf "${GREEN}R 3.6.1 installed! ${NC}\n"

sudo chmod -R 777 /usr/local/lib/R/library
sudo chmod -R 777 /usr/local/lib/R/

R
install.packages("randomForest")
install.packages("bioacoustics")
install.packages("audio")
install.packages("rstudioapi")

printf "${GREEN}Install R packages done! ${NC}\n"

# cd /home/pi/Desktop/Bioacoustics
# Rscript Deploy_bats.R








