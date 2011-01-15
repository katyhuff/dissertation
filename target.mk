# forces all (well, almost all) the builtin rules to be removed. This is
# crucial: we don't want make to know how to build anything. Below, we'll
# tell it how to build everything, and we don't want it using any other
# rules.
.SUFFIXES:


# Define the target directory(ies).
#
OBJDIR := $(TEX_DEST_DIR)

#EXTRATARGETS := $(wildcard _common)
EXTRATARGETS := 

# Define the rules to build in the target subdirectories.
#
MAKETARGET = $(MAKE) --no-print-directory -C $@ -f $(CURDIR)/Makefile \
		 _MAKE_TARGET=T SRCDIR=$(CURDIR) $(MAKECMDGOALS)

.PHONY: $(OBJDIR) $(EXTRATARGETS)
$(OBJDIR) $(EXTRATARGETS):
	+@[ -d $@ ] || mkdir -p $@
	+@$(MAKETARGET)

$(OBJDIR) : $(EXTRATARGETS)


# These rules keep make from trying to use the match-anything rule below to
# rebuild the makefiles--ouch!  Obviously, if you don't follow my convention
# of using a `.mk' suffix on all non-standard makefiles you'll need to change
# the pattern rule.
#
Makefile : ;
%.mk :: ;


# Anything we don't know how to build will use this rule.  The command is a
# do-nothing command, but the prerequisites ensure that the appropriate
# recursive invocations of make will occur.
#
% :: $(EXTRATARGETS) $(OBJDIR) ;


# The clean rule is best handled from the source directory: since we're
# rigorous about keeping the target directories containing only target files
# and the source directory containing only source files, `clean-all' is as
# trivial as removing the target directories!
#
.PHONY: clean-all
clean-all:
	$(if $(EXTRATARGETS),rm -f $(EXTRATARGETS)/*)
	rm -rf $(OBJDIR)
