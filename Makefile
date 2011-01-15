################################################
# file: Makefile
# Makefile for latex
#
# @Author: SUN, Tong
# Copyright (c)2001 - 2003, Tong SUN, all right reserved
# @Version: $Date: 2006/10/12 18:13:16 $ $Revision: 1.18 $
# @Home URL: http://xpt.sourceforge.net/
#
# Readme begins:
# 
# This is a generic makefile to create output from a Latex file.
# 
# It will run the designated LaTeX FILE through TeX in turn until all
# references are resolved (including BibTeX), and all indexes are built.
# 
# It can also generate .pdf, .html, .txt or .rtf files.
# 
# For futher information, refer to file latexmake.README
# To get online help, type 'make help'
# 
# Readme ends.
#  cat Makefile | sed -n '1,/# [R]eadme /d; /# [R]eadme /q; p' | cut -c3- > latexmake.diz
# 
# {{{ Commentary: 

# 
#  To make the latex file 'latex_file.tex', issue:
#
#   make TEX_SOURCE_BASE=latex_file
#  or rather:
#   export TEX_SOURCE_BASE=latex_file
#   make
#  
# Basically you need to set the TEX_SOURCE_BASE variable (no .tex extesion)
# before invoking make.  Using 'make check' can have 'make' makes suggestion
# for you. You can clean all the generated files for this particular
# Latex file easily using 'make clean'.

# If the TEX_DEST_DIR variable is set, all generated files (.ps, .pdf...)
# will end up in that particular directory. The default is current dir. The
# benefit of setting this variable is that you can avoid cluttering your
# Latex source directory with generated and intermediate files, so that your
# Latex source directory is always ready for backup. Furthermore, the rich
# set of clean commands will make it a easy job to ensure the backup file is
# always the smallest.
#  
# It default makes only .dvi file, and no output unless errors occur
# You can also issue 'make view' to view the result right after the make
#
# To generate other formats, issue
#  
#   make ps
# and/or,
#   make pdf
#   make html
#   make txt
#   _MAKE_TARGET=T make rtf
#  
#  or simply:
#   make all
#  to make both ps and pdf files.
#
# The general procedure would be
#   'make view' once, then 'make' repeatly until you are fully satisfied
#   'make all', or '_MAKE_TARGET=T make html' for the final blast
# 
#  Targets           Explanation
#  -------------------------------------------
#  dvi           dvi format
#  ps            postscript
#  pdf           pdf Adobe
#  html          for web browser
#  txt           normal plain text file
#  rtf           for M$ Word/WordPad
# 
# To clean up:
# 
#  make clean-bak	: clean all backups of source files
#  make clean	: clean generated files from TEX_SOURCE_BASE
#  make clean-gen	: clean all generated ps/pdf related files
#  make clean-th	: clean all generated text/html related files
#  make clean-all	: wipe out TEX_DEST_DIR directory entirely
#

# }}} end commentary.
#
# {{{ Credit: 
# 
# The following files helped when the first draft of this
# make file was constructed:
#
# Makefile skeleton, from chris beggy chrisb@kippona.com, 
# Skeleton Id: skel-make-latex.el,v 1.3 2001/01/17 23:52:17 chrisb Exp 
#
# LaTeX Makefile, from s.m.vandenoord@@student.utwente.nl (Stefan van den Oord)
# Date   : July 15, 1999
# 
# }}}
#
# {{{ License: 
# 
# Permission to use, copy, modify, and distribute this software and its
# documentation for any purpose and without fee is hereby granted, provided
# that the above copyright notices appear in all copies and that both those
# copyright notices and this permission notice appear in supporting
# documentation, and that the names of author not be used in advertising or
# publicity pertaining to distribution of the software without specific,
# written prior permission.  Tong Sun makes no representations about the
# suitability of this software for any purpose.  It is provided "as is"
# without express or implied warranty.
#
# TONG SUN DISCLAIM ALL WARRANTIES WITH REGARD TO THIS SOFTWARE, INCLUDING ALL
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO EVENT SHALL ADOBE
# SYSTEMS INCORPORATED AND DIGITAL EQUIPMENT CORPORATION BE LIABLE FOR ANY
# SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER
# RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF
# CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN
# CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
#
# }}}
# 
################################################

# {{{ Defines:

# .............................................................. &ss ...
# here's the system dependent stuff
#

ifndef TEXEDITOR
TEXEDITOR = emacs
endif

ifndef LATEX
LATEX = texi2dvi -q
endif

ifndef DVIPS
DVIPS=dvips
endif

ifndef PDFLATEX
PDFLATEX = pdflatex
#PDFLATEX = texi2pdf -q -p
#PDFLATEX = ps2pdf
#PDFLATEX = dvipdfmx
endif

ifndef HTML2TEXT
HTML2TEXT=w3m -dump -cols 78 
endif

ifndef LATEX2RTF
LATEX2RTF=latex2rtf
endif

ifndef MAKEFILE
MAKEFILE=Makefile
endif

ifndef DVIVIEWER
DVIVIEWER=xdvi
endif

ifndef PSVIEWER
PSVIEWER=gv
endif

ifndef PDFVIEWER
PDFVIEWER=open
endif

ifndef TEX_DEST_DIR
TEX_DEST_DIR=.
NO_TEX_DEST_DIR=T
endif

define rule-tex2htm
        latex2html -verbosity 0 -split 0 -nonavigation -noinfo -noaddress -dir ${TEX_DEST_DIR} $< 
        @cd ${TEX_DEST_DIR} && { rm $@; perl -p0e 's#\n<P>\n<BR><HR>\n##s' index.html > $@; rm -f index.html labels.pl WARNINGS ;}
endef

define rule-tex2txt
        $(HTML2TEXT) $< | sed '$$d' > $@
endef

ifdef LM_USE_HEVEA
define rule-tex2htm
	hevea -I $(SRCDIR) -exec xxdate.exe $<
	sed -i '/HEVEA command line/d; s|<FONT *COLOR=[^>]*>|<FONT>|; /<!--FOOTER-->/{N;N;d};' $@
endef

define rule-tex2txt
	hevea -I $(SRCDIR) -exec xxdate.exe -text -w 78 $<
	sed -i -n '/^--*-$$/q; p;' $@
endef
endif

define rule-finish
	@printf "\n== The $@ file '$(TEX_DEST_DIR)/$<' generated\n\n\n"
endef

# for rules like ${TEX_DEST_DIR}/$(TEX_SOURCE_BASE).ext
define rule-finish-shortfn
	@printf "\n== The $@ file '$<' generated\n\n\n"
endef

# }}}

# {{{ Rules:

ifndef _MAKE_TARGET
include target.mk
else
#----- Begin Normal makefile rules

VPATH = $(SRCDIR)
VPATH += $(CURDIR)

# .............................................................. &ss ...
# here are the default rules
#

# Disable standard pattern rule:
%.dvi: %.tex

# Do not delete the following targets:
.PRECIOUS: %.aux %.bbl

#%.dvi: %.tex
#	$(LATEX) -I $(SRCDIR) -o $@ $<

#%.ps : %.dvi
#	$(DVIPS) -o $@ $< 

## Rule for ps2pdf:
#%.pdf : %.ps %.dvi
#	$(PDFLATEX) $< $@

## Rule for dvipdfm
%.pdf : %.tex
	$(PDFLATEX) $<

%.html : %.tex
	$(rule-tex2htm)

%.txt : %.tex
	$(rule-tex2txt)

# .............................................................. &ss ...

${TEX_DEST_DIR}/%.rtf : %.tex ${TEX_DEST_DIR}
	$(LATEX2RTF) < $< > $@

# .............................................................. &ss ...
# Include extra rules if any 
#
EXTRA_INCLUDES:=$(wildcard makefile.*.mk)
ifneq ($(strip $(EXTRA_INCLUDES)),)
  include $(EXTRA_INCLUDES)
endif

# .............................................................. &ss ...
# here are the targets
#

# default is to build dvi
# it will be rebuilt if *any* .tex and .bib in current dir changed

dvi : $(TEX_SOURCE_BASE).dvi

$(TEX_SOURCE_BASE).dvi: $(wildcard $(SRCDIR)/*.tex) $(wildcard $(SRCDIR)/*.bib)

bib : $(wildcard $(SRCDIR)/*.bib)
	ln -sf $(SRCDIR)/*.bib .
	bibtex $(TEX_SOURCE_BASE)

view: $(TEX_SOURCE_BASE).dvi
	$(DVIVIEWER) ${TEX_SOURCE_BASE}.dvi &

view-dvi: $(TEX_SOURCE_BASE).dvi
	$(DVIVIEWER) ${TEX_SOURCE_BASE}.dvi &

view-ps: $(TEX_SOURCE_BASE).ps
	$(PSVIEWER) ${TEX_SOURCE_BASE}.ps &

view-pdf: $(TEX_SOURCE_BASE).pdf
	$(PDFVIEWER) ${TEX_SOURCE_BASE}.pdf &

${TEX_DEST_DIR}:
	@[ -d $@ ] || mkdir -p $@

# =========================================================== &PHONY ===
## == PHONY 
## 
.PHONY : list help usage check edit view-log clean cleangen clean-bak clean-th

# You can change the 'meaning' of 'all' the way you want
# by adding or deleting targets
all :  dvi ps pdf

view-log: 
	$(PAGER) ${TEX_SOURCE_BASE}.log

ps : $(TEX_SOURCE_BASE).ps
	$(rule-finish)

pdf : $(TEX_SOURCE_BASE).pdf
	$(rule-finish)

html : $(TEX_SOURCE_BASE).html
	$(rule-finish)

# there might be two ways to make it, so need two depend rules
$(TEX_SOURCE_BASE).html: $(wildcard $(SRCDIR)/*.tex)
${TEX_DEST_DIR}/$(TEX_SOURCE_BASE).html: $(wildcard *.tex)

txt : $(TEX_SOURCE_BASE).txt
	$(rule-finish)

rtf : ${TEX_DEST_DIR}/$(TEX_SOURCE_BASE).rtf
	$(rule-finish-shortfn)

${TEX_DEST_DIR}/$(TEX_SOURCE_BASE).rtf: $(wildcard *.tex)

clean: 
	rm -vf ${TEX_SOURCE_BASE}.dvi ${TEX_SOURCE_BASE}.log ${TEX_SOURCE_BASE}.aux ${TEX_SOURCE_BASE}.bbl ${TEX_SOURCE_BASE}.blg ${TEX_SOURCE_BASE}.ilg ${TEX_SOURCE_BASE}.toc ${TEX_SOURCE_BASE}.lof ${TEX_SOURCE_BASE}.lot ${TEX_SOURCE_BASE}.idx ${TEX_SOURCE_BASE}.ind ${TEX_SOURCE_BASE}.out ${TEX_SOURCE_BASE}.fff ${TEX_SOURCE_BASE}.ttt

clean-gen :
	rm -vf *.dvi *.log *.aux *.bbl *.blg *.ilg *.toc *.lof *.lot *.idx *.ind *.out *.ps *.pdf  

clean-th :
	rm -vf *.txt *.html *.css

# .............................................................. &ss ...

#----- End Normal makefile rules
endif

edit: 
	$(TEXEDITOR) ${TEX_SOURCE_BASE}.tex & 

clean-bak :
	rm -vf *~

# .............................................................. &ss ...
#
#TEX_SOURCE_BASE is get from environment or command line

check:
# Make sure the TEX_SOURCE_BASE is set and help set it if not.
	@[ $(NO_TEX_DEST_DIR) ] && printf "Warning: TEX_DEST_DIR not set (will generate files to the current directory)\nUse the following command to set destination directory for generated files:\n export TEX_DEST_DIR=\n\n" || true
	@if [ $${TEX_SOURCE_BASE:+T} ]; then \
	  printf "TEX_SOURCE_BASE=${TEX_SOURCE_BASE}\nTEX_DEST_DIR=${TEX_DEST_DIR}\n"; \
	else  { \
		if [ `ls *.tex | wc -l` = "1" ]; then \
			TEX_SOURCE_BASE=`basename \`ls *.tex\` .tex`; \
			true; \
		else \
			TEX_SOURCE_BASE=`echo $$PWD|tr '/' '\n'|tail -1`; \
			true; \
		fi; \
	printf "\nPlease set\n\n export TEX_SOURCE_BASE=$$TEX_SOURCE_BASE\nor,\n setenv TEX_SOURCE_BASE $$TEX_SOURCE_BASE\n"; \
	}; fi

# Self maintenance
list:
	@grep -E '^[a-zA-Z0-9_]+[ ]*:' ${MAKEFILE} | \
	awk -F':' '{print $$1 }'

help:
	@cat ${MAKEFILE} | sed -n '1,/ Commentary/d; / end commentary/q; p' | cut -c3-
	@echo To get the help from the tools used:
	@echo type \'texi2dvi --help\'
	@echo type \'texi2pdf --help\'

# }}}

## end of Makefile
