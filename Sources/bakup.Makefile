#######################################################################
#######################################################################
##                                                                   ##
##  HU-Prolog         Public Domain Version       Release  2.025     ##
##                                                                   ##
##  Author(s): 87-89  Christian Horn, Mirko Dziadzka, Matthias Horn  ##
##             90-93  Mirko Dziadzka                                 ##
##                    Humboldt-Universitaet zu Berlin, FB Informatik ##
##                    email: dziadzka@informatik.hu-berlin.de        ##
##                                                                   ##
##  HU-Prolog 2.025 can be copied, modified and distributed freely   ##
##  for any non-commercial purposes under the conditions that all    ##
##  files include this header and that the message                   ##
##  "HU-Prolog public domain version" and the names of the authors   ##
##  will be displayed, when HU-Prolog is called.                     ##
##                                                                   ##
#######################################################################
#######################################################################

## For a quick version of HU-Prolog use the definition 
## QUICK_BUT_DIRTY in `config.h' and uncomment the following line 
Q=q

## Standard Definitions
LINT=/usr/bin/lint
HELPDIR=../Help
PATCHES=../Patches
O=o

### Configuration for a generic HU-Prolog

### SYSTEM should be BSD or SYSV
SYSTEM=BSD

### the name of the Bourne-Shell
SHELL=/bin/sh

### TERMIO should be 'termio' or 'termios'
### termios is the POSIX version
TERMINAL=termios

### the C-Compiler
CC=gcc -ansi

### C-Flags
CFLAGS=-O 

### Libraries (mathlib and termcap/termlib/curses expected)
LIBS=-lm -ltermlib -ldl

### where HU-PROLOG should be installed
BINDIR=/usr/local/bin

### where the libaries should go
LIBDIR=/usr/local/lib

### where the M#manual should go
MANDIR=/usr/local/man/man1

### the name of the executable
HU_PROLOG=prolog

### the name of the online help libary
PROLOG_HELP=prolog.hlp

### the name of the manual
PROLOG_MAN=prolog.1

### How to format the manual pages
MANROFF=groff -man -Tascii

### the name of *this* Makefile
MAKEFILE=Makefile

STDPLGRC=\"$(LIBDIR)/huprolog/prologrc\"
STDHELP=\"$(LIBDIR)/$(PROLOG_HELP)\"

INSTALL=cp
INSTALL_EXEC=$(INSTALL)
INSTALL_DATA=$(INSTALL)

#############################################################
##       nothing to change after this point                ##
#############################################################

MAKEFILE=Makefile

SOURCES=arith.c atoms.c atom.tab datab.c eval.c $(Q)exec.c\
	io.c types.c memory.c misc.c prolog.c read.c sys.c\
	$(Q)uni.c user.c win.c write.c charcl.c help.c $(TERMINAL).c

DEFINES=atoms.def 

HEADERS=atoms.h extern.h files.h memory.h help.h\
	config.h types.h window.h misc.h charcl.h

OBJ =   arith.$(O) atoms.$(O) datab.$(O) eval.$(O) io.$(O)\
	memory.$(O) misc.$(O) prolog.$(O) read.$(O) sys.$(O)\
	user.$(O) win.$(O) write.$(O) charcl.$(O) help.$(O)\
	$(TERMINAL).$(O) $(Q)exec.$(O) $(Q)uni.$(O) types.$(O) mylib.$(O)

OBJECTS = $(OBJ) 

C_SOURCES=							\
	arith.c atom.tab atoms.c atoms.def charcl.c datab.c 	\
	eval.c exec.c io.c mem_as.c mem_et.c mem_t1.c mem_t2.c 	\
	memory.c misc.c mkatoms.c mkheader.c mkmagic.c help.c	\
	mkversion.c nrev prolog.c qexec.c quni.c read.c sys.c	\
	types.c uni.c user.c win.c $(TERMINAL).c mylib.c			

H_SOURCES= 							\
	charcl.h config.h extern.h files.h help.h memory.h 	\
	misc.h types.h window.h

$(HU_PROLOG) : $(OBJECTS) 
	@$(MAKE) version.$(O)
	$(CC) $(LDFLAGS) -o $(HU_PROLOG) $(OBJECTS) version.$(O) $(LIBS)

config.h: cflags.log
	@echo new parameters in $(MAKEFILE)  -- touch config.h
	@touch config.h

cflags.log: $(MAKEFILE)
	@-rm -f cflags.tmp
	@echo CC=$(CC) 	>> cflags.tmp
	@echo CFLAGS=$(CFLAGS) >> cflags.tmp
	@echo SYSTEM=$(SYSTEM) >> cflags.tmp
	@move-if-change cflags.tmp cflags.log

$(OBJECTS): $(HEADERS)
atoms.$(O): atom.tab
help.$(O) eval.${O} prolog.${O}:  paths.h

.c.$(O):
	$(CC) -c $(CFLAGS) -D$(SYSTEM)  $*.c 

atoms.h: atoms.tmp
	@move-if-change atoms.tmp $@

atoms.tmp: atoms.def
	@$(MAKE) mkatoms
	@echo "/* THIS FILE IS GENERATED AUTOMATICALLY --DON'T EDIT */" > $@
	@echo  >> $@
	@mkatoms < atoms.def >> $@

paths.h: paths.tmp
	@move-if-change	paths.tmp $@

paths.tmp:
	@$(MAKE) mkheader
	@echo "/* THIS FILE IS GENERATED AUTOMATICALLY --DON'T EDIT */" > $@
	@echo     >> $@
	@mkheader >> $@
	@echo     >> $@
	@if [ x$(STDPLGRC) != x ] ; then echo '#define STDPLGRC' $(STDPLGRC)  >> $@; fi 	
	@if [ x$(STDHELP) != x ] ; then echo '#define STD_HELP_FILE' $(STDHELP)  >> $@; fi 	
	@echo     >> $@
	@echo '/* end of file */'    >> $@

.sh:	
	cp $*.sh $*
	chmod +x $*

.SUFFIXES: .$(O) .ln .c .h .def .sh

nounix: realclean  $(HEADERS) version.c $(PROLOG_HELP) paths.h prolog.txt
	rm -f mkversion mkheader mkdiff mkatoms mkmagic

PATCHLEVEL:
	@echo PATCHLEVEL is unknown, i take 0
	@echo -n 0 > PATCHLEVEL

RELEASE:
	@echo RELEASE is unknown, i take 0
	@echo -n 0 > RELEASE

MAGIC: $(C_SOURCES) atoms.h atom.tab 
	$(MAKE) mkmagic
	mkmagic > MAGIC

mkmagic: mkmagic.c
	$(CC) -o mkmagic mkmagic.c $(LIBS)

mkatoms: mkatoms.c
	$(CC) -o mkatoms mkatoms.c $(LIBS)

mkversion: mkversion.c RELEASE PATCHLEVEL MAGIC
	$(CC) -o $@  -D$(SYSTEM) \
		 -DRELEASE=`cat RELEASE` \
		 -DPATCHLEVEL=`cat PATCHLEVEL` \
		 -DMAGIC_NUMBER=`cat MAGIC` mkversion.c  $(LIBS)

mkheader: mkheader.c RELEASE PATCHLEVEL
	$(CC) -o $@ -D$(SYSTEM) \
		 -DRELEASE=`cat RELEASE` \
		 -DPATCHLEVEL=`cat PATCHLEVEL`  mkheader.c  $(LIBS)

newversion: PATCHLEVEL RELEASE
	@cp $(MAKEFILE) bakup.$(MAKEFILE)
	@make realclean
	@cp bakup.$(MAKEFILE) $(MAKEFILE)
	@echo backup actual version in OLD.TAR ...
	@tar cf OLD.TAR *
	@echo generate new version ...
	@expr `cat PATCHLEVEL` + 1 > PATCHLEVEL.TMP
	@mv PATCHLEVEL.TMP PATCHLEVEL
	@$(MAKE) header.txt
	@cat header.txt
	@echo change all headers ...
	@$(MAKE) change_head
	@change_head $(C_SOURCES) $(H_SOURCES)
	@mv CHANGE.LOG CHANGE.old
	@echo \#`cat RELEASE`\.`cat PATCHLEVEL`\# `date` >> CHANGE.LOG
	@echo >> CHANGE.LOG
	@cat CHANGE.old >> CHANGE.LOG
	@$(MAKE) nounix
	
	
version.c : $(C_SOURCES)
	$(MAKE) mkversion
	mkversion > version.c

header.txt : PATCHLEVEL RELEASE
	$(MAKE) mkheader
	mkheader > header.txt

lint:   
	@make nounix
	@make Q= _lint 
	wc lint.out


install: $(HU_PROLOG) $(PROLOG_HELP) $(PROLOG_MAN)
	strip $(HU_PROLOG)
	$(INSTALL_EXEC) $(HU_PROLOG) $(BINDIR)
	-chmod go=x $(BINDIR)/$(HU_PROLOG)
	$(INSTALL_DATA) $(PROLOG_HELP) $(LIBDIR)
	-chmod go=r $(LIBDIR)/$(PROLOG_HELP)
	$(INSTALL_DATA) $(PROLOG_MAN) $(MANDIR)
	-chmod go=r $(MANDIR)/$(PROLOG_MAN)

$(PROLOG_HELP): force_make
	(cd $(HELPDIR) ; make ; mv help.lib $(PROLOG_HELP))
	mv $(HELPDIR)/$(PROLOG_HELP) $(PROLOG_HELP)

prolog.txt: prolog.man
	$(MANROFF) prolog.man > prolog.txt

$(PROLOG_MAN): prolog.man
	cp prolog.man $(PROLOG_MAN)

tar:	hu-prolog.tar
	
hu-prolog.tar:	realclean 
	tar cf hu-prolog.tar *

clean:
	-rm -f *.$(O) core prolog 
	-rm -f lint.out *.ln *.lint *.tmp
	-rm -f mkheader change_head header.txt
	-rm -f mkversion mkatoms mkmagic
	-(cd $(HELPDIR) ; make clean)

realclean: clean remove-makefile
	-rm -f atoms.h paths.h MAGIC cflags.log
	-rm -f OLD.TAR hu-prolog.tar
	-rm -f prolog.shar*

diff: 	nounix mkdiff.sh
	sh mkdiff.sh $(PATCHES)

prolog.shar: nounix
	shar -n HU-Prolog-`cat RELEASE`.`cat PATCHLEVEL` \
	-s dziadzka@informatik.hu-berlin.de -M -F -c \
	-o prolog.shar -l 90 *
	#shar -bCems * > prolog.shar
	mv prolog.shar* $(DISTRIBUTION)

force_make:

remove-makefile:
	@mv $(MAKEFILE) $(MAKEFILE)~
	@echo "configure-the-system:"		  	>> $(MAKEFILE)
	@echo "	@echo run Configure first" 	  	>> $(MAKEFILE)
	@echo ".DEFAULT:" 				>> $(MAKEFILE)
	@echo "	@echo run Configure first" 		>> $(MAKEFILE)
## end of file ##
