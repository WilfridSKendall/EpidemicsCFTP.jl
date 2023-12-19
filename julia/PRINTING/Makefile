# This Makefile sits in the PRINTING directory, and captures PDFs 
# for the various Makefiles and test suites and other material.

SHELL           := /usr/bin/bash
LOCATION        := $(dir $(shell pwd))
QUARTO          := /usr/local/bin/quarto

listings: listings-main listings-EpidemicsCFTP listings-EpidemicsUtilities
	make Makefile.pdf

listings-main:
	make --directory=.. README.pdf Makefile.pdf theme.pdf blank-theme.pdf test-theme.pdf 
	-cp ../README.pdf Main-README.pdf
	-mv ../Makefile.pdf Main-Makefile.pdf
	-mv ../theme.pdf Main-theme.pdf
	-mv ../blank-theme.pdf Main-blank-theme.pdf
	-mv ../test-theme.pdf Main-test-theme.pdf

listings-EpidemicsCFTP:
	make --directory=../EpidemicsCFTP listings
	-cp ../EpidemicsCFTP/README.pdf EpidemicsCFTP-README.pdf
	-mv ../EpidemicsCFTP/Makefile.pdf EpidemicsCFTP-Makefile.pdf 
	-mv ../EpidemicsCFTP/EpidemicsCFTP-test.pdf .

listings-EpidemicsUtilities:
	make --directory=../EpidemicsUtilities listings
	-cp ../EpidemicsUtilities/README.pdf EpidemicsUtilities-README.pdf
	-mv ../EpidemicsUtilities/Makefile.pdf EpidemicsUtilities-Makefile.pdf
	-mv ../EpidemicsUtilities/EpidemicsUtilities-test.pdf .
	-mv ../EpidemicsUtilities/default_theme.pdf EpidemicsUtilities-default_theme.pdf




# --------------------
## List Makefile
include $(HOME)/lib/makefiles/listing-makefile.mak
