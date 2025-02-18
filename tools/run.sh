#!/bin/bash
#
# Install additional software not included in the Conda environment
#

source ../PARAMS.sh

echo ">>> INSTALL PERL - ENVIRONMENT <<<"
echo "Note: This might take some time"
# Note: All Perl libraries might be possible to install to Conda but from compatibility issues we have install them separately. Also, Perl likes to break Conda environments so it's safer to make them separate.
# Note: If you have problems with local::lib makes sure it's correctly installed system-wide or in Conda and that Perl can see it but DO NOT activate Conda environment.

if [ -z ${CONDA_PREFIX} ]; then
    echo "Variable \$CONDA_PREFIX is not set. Please make sure you specified if in PARAMS.sh."
    exit
fi

export PERL5LIB=${PERL5LIB}:${CONDA_PREFIX}/envs/teraseq/lib/site_perl/5.26.2/
export PATH=${PATH}:${CONDA_PREFIX}/envs/teraseq/bin

cd $INSTALL/

git clone https://github.com/jizhang/perl-virtualenv.git # commit f931774
cd perl-virtualenv/
git reset f931774 --hard
chmod u+x virtualenv.pl
./virtualenv.pl teraseq
source teraseq/bin/activate
# Make sure you have cpanm working - redownload
curl -L https://cpanmin.us/ -o teraseq/bin/cpanm
chmod +x teraseq/bin/cpanm
which perl && perl -v
which cpanm && cpanm -v
echo $PERL5LIB

echo ">> INSTALL PERL - MODULES <<"
# Note: If installation of a module fails, try to rerun the installation with `--force`.

cpanm inc::Module::Install@1.19
cpanm autodie@2.29
cpanm DBI@1.642
cpanm Devel::Size@0.83
cpanm Getopt::Long::Descriptive@0.104
cpanm IO::File@1.39
cpanm IO::Interactive@1.022
cpanm --force IO::Uncompress::Gunzip
cpanm Params::Validate@1.29
cpanm Params::Util@1.07
cpanm Sub::Install@0.928
cpanm Modern::Perl@1.20190601
cpanm --force MooseX::App::Simple@1.41
cpanm --force MooseX::App::Command
cpanm --force MooseX::Getopt::Meta::Attribute::Trait::NoGetopt@0.74

echo ">> INSTALL PERL - GENOO <<"
# Note: Please use the GitHub version as the CPAN version is not up-to-date:
git clone --recursive https://github.com/genoo/GenOO.git teraseq/lib/perl5/GenOO_git # commit 6527029
cd teraseq/lib/perl5/GenOO_git/
git reset 6527029 --hard
cd ../
mkdir GenOO
cp -r GenOO_git/lib/GenOO/* GenOO/


echo ">> INSTALL PERL - CLIPSeqTools <<"
# Install CLIPSeqTools
cpanm CLIPSeqTools@0.1.9

echo ">> INSTALL PERL - GenOOx minimap2 parser <<"
cp -r $DIR/misc/GenOOx/* $INSTALL/perl-virtualenv/teraseq/lib/perl5/GenOOx/
deactivate

echo ">>> INSTALL NANOPOLISH <<<"

CONDA_BIN="$CONDA_PREFIX/bin"

# version used for polya tail estimates
# Note: We used commit 480fc85 but there are some make issues after the latests commits and --reset won't fix it. Version 0.14.0 doesn't seem to have any major changes that would change the results of the analysis
cd $INSTALL/
git clone --recursive https://github.com/jts/nanopolish.git
mv nanopolish nanopolish-480fc85
cd nanopolish-480fc85/
git reset 480fc85 --hard
#wget https://github.com/jts/nanopolish/archive/refs/tags/v0.14.0.tar.gz -O nanopolish.tar.gz
#tar xvzf nanopolish.tar.gz
#cd nanopolish-0.14.0/
# fix outdated link to eigen and some code
sed -i 's#http://bitbucket.org/eigen/eigen/get/$(EIGEN_VERSION).tar.bz2#https://gitlab.com/libeigen/eigen/-/archive/$(EIGEN_VERSION)/eigen-$(EIGEN_VERSION).tar.bz2#' Makefile
sed -i 's/tar -xjf $(EIGEN_VERSION).tar.bz2/tar -xjf eigen-$(EIGEN_VERSION).tar.bz2/' Makefile
sed -i 's/eigen-eigen-\*/eigen-$(EIGEN_VERSION)/' Makefile
## Commit 18d6e3 removed fast5 necessary for this commit and --recursive and git reset won't work, we have to get it separately
rm -rf fast5
git clone https://github.com/mateidavid/fast5.git
cd fast5/
git reset 18d6e34 --hard
cd ../
rm -rf htslib
git clone --recursive https://github.com/samtools/htslib.git
cd htslib/
git reset 3dc96c5 --hard
cd ../
make
ln -s $(pwd)/nanopolish $CONDA_BIN/nanopolish

# new version with polya hmm scripts
cd $INSTALL/
git clone --recursive https://github.com/jts/nanopolish.git
mv nanopolish nanopolish-ab9722b
cd nanopolish-ab9722b/
git reset ab9722b --hard

source $CONDA_PREFIX/bin/activate # Source Conda base
conda activate teraseq

echo ">>> INSTALL GeneCycle R PACKAGE <<<"
# This R-package is not available from Conda so we have to install it manually
# Installing packages manually in Conda environment is NOT recommended

#Rscript -e 'install.packages("GeneCycle", repos="https://cloud.r-project.org")'
Rscript -e 'install.packages(c("longitudinal", "fdrtool"), repos = "http://cran.us.r-project.org"); install.packages("https://cran.r-project.org/src/contrib/GeneCycle_1.1.5.tar.gz", repos=NULL, type="source")'

echo ">>> INSTALL CUTADAPT <<<"

cd $INSTALL/
mkdir cutadapt-2.5/
cd cutadapt-2.5/
python3 -m venv venv # Make Python virtual environment
source venv/bin/activate
python3 -m pip install --upgrade pip
pip3 install cutadapt==2.5 pysam numpy pandas matplotlib seaborn
which cutadapt # Check installation
cutadapt --version
deactivate

echo ">>> INSTALL DEEPTOOLS <<<"
cd $INSTALL/
mkdir deepTools-3.5.0
cd deepTools-3.5.0/
python3 -m venv venv
source venv/bin/activate
python3 -m pip install --upgrade pip
pip3 install wheel
pip3 install deeptools==3.5.0
# pip3 install -Iv deeptools==3.5.0
deeptools --version
deactivate

echo ">>> INSTALL ONT-FAST5-API <<<"
cd $INSTALL/
mkdir ont-fast5-api
cd ont-fast5-api/
python3 -m venv venv
source venv/bin/activate
pip install ont-fast5-api==3.3.0 h5py seaborn
deactivate

echo ">>> INSTALL JVARKIT <<<"

cd $INSTALL/
git clone "https://github.com/lindenb/jvarkit.git" # commit "014d3e9"
cd jvarkit/
git reset 014d3e9 --hard
./gradlew biostar84452
mkdir $CONDA_PREFIX/share/jvarkit
ln -s $INSTALL/jvarkit/dist/biostar84452.jar $CONDA_PREFIX/share/jvarkit/remove-softlip.jar

echo ">>> INCREASE FASTQC RAM <<<"

sed -i 's/-Xmx250m/-Xmx5g/g' $CONDA_PREFIX/opt/fastqc-*/fastqc

echo ">>> ALL DONE <<<"
