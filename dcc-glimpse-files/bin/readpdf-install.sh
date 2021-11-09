#!/bin/ksh

set here [ pwd ]

mkdir readpdf-INSTALL

cd readpdf-INSTALL

wget http://packages.sw.be/perl-Font-TTF/perl-Font-TTF-0.45-1.el5.rf.noarch.rpm
wget http://packages.sw.be/perl-Text-PDF/perl-Text-PDF-0.29a-1.el5.rf.noarch.rpm
wget http://search.cpan.org/CPAN/authors/id/C/CD/CDOLAN/CAM-PDF-1.52.tar.gz

rpm -i ./perl-Font-TTF-0.45-1.el5.rf.noarch.rpm
rpm -i ./perl-Text-PDF-0.29a-1.el5.rf.noarch.rpm

tar xvzf CAM-PDF-1.52.tar.gz

cd CAM-PDF-1.52

perl Makefile.PL
make
make test
make install

cd $here
rm -rf readpdf-INSTALL

yum install perl-Archive-Zip
