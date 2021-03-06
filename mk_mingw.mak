# Makefile for Universal Ctags under Win32 with MinGW compiler

include source.mak

REGEX_DEFINES = -DHAVE_REGCOMP -D__USE_GNU -DHAVE_STDBOOL_H -DHAVE_STDINT_H -Dstrcasecmp=stricmp

CFLAGS = -Wall -std=gnu99
# sizeof (size_t) == sizeof(unsigned long) == 4 on i686-w64-mingw32-gcc.
SIZE_T_FMT_CHAR='""'
COMMON_DEFINES=-DUSE_SYSTEM_STRNLEN
DEFINES = -DWIN32 $(REGEX_DEFINES) -DHAVE_PACKCC $(COMMON_DEFINES)
INCLUDES = -I. -Imain -Ignu_regex -Ifnmatch -Iparsers
CC = gcc
WINDRES = windres
OPTLIB2C = ./misc/optlib2c
PACKCC   = ./packcc.exe
OBJEXT = o
RES_OBJ = win32/ctags.res.o
ALL_OBJS += $(REGEX_OBJS)
ALL_OBJS += $(FNMATCH_OBJS)
ALL_OBJS += $(WIN32_OBJS)
ALL_OBJS += $(PEG_OBJS)
ALL_OBJS += $(RES_OBJ)
VPATH = . ./main ./parsers ./optlib ./read ./win32

ifeq (yes, $(WITH_ICONV))
DEFINES += -DHAVE_ICONV
LIBS += -liconv
endif

ifdef DEBUG
DEFINES += -DDEBUG
OPT = -g
else
OPT = -O4 -Os -fexpensive-optimizations
LDFLAGS = -s
endif

.SUFFIXES: .c .o .ctags .peg

#
# Silent/verbose commands
#
# when V is not set the output of commands is omitted or simplified
#
V	 ?= 0
CC_FOR_PACKCC ?= $(CC)

SILENT   = $(SILENT_$(V))
SILENT_0 = @
SILENT_1 =

V_CC	 = $(V_CC_$(V))
V_CC_0	 = @echo [CC] $@;
V_CC_1	 =

V_OPTLIB2C   = $(V_OPTLIB2C_$(V))
V_OPTLIB2C_0 = @echo [OPTLIB2C] $@;
V_OPTLIB2C_1 =

V_PACKCC   = $(V_PACKCC_$(V))
V_PACKCC_0 = @echo [PACKCC] $@;
V_PACKCC_1 =

V_WINDRES   = $(V_WINDRES_$(V))
V_WINDRES_0 = @echo [WINDRES] $@;
V_WINDRES_1 =


.c.o:
	$(V_CC) $(CC) -c $(OPT) $(CFLAGS) $(DEFINES) $(INCLUDES) -o $@ $<

%.c: %.ctags $(OPTLIB2C)
	$(V_OPTLIB2C) $(OPTLIB2C) $< > $@

peg/%.c peg/%.h: peg/%.peg $(PACKCC)
	$(V_PACKCC) $(PACKCC) $<

all: $(PACKCC) ctags.exe readtags.exe

ctags: ctags.exe

$(PACKCC_OBJS): $(PACKCC_SRCS)
	$(V_CC) $(CC_FOR_PACKCC) -c $(OPT) $(CFLAGS) $(COMMON_DEFINES) -DSIZE_T_FMT_CHAR=$(SIZE_T_FMT_CHAR) -o $@ $<

$(PACKCC): $(PACKCC_OBJS)
	$(V_CC) $(CC_FOR_PACKCC) $(OPT) -o $@ $^

ctags.exe: $(ALL_OBJS) $(ALL_HEADS) $(PEG_HEADS) $(PEG_EXTRA_HEADS) $(REGEX_HEADS) $(FNMATCH_HEADS) $(WIN32_HEADS)
	$(V_CC) $(CC) $(OPT) $(CFLAGS) $(LDFLAGS) $(DEFINES) $(INCLUDES) -o $@ $(ALL_OBJS) $(LIBS)

$(RES_OBJ): win32/ctags.rc win32/ctags.exe.manifest win32/resource.h
	$(V_WINDRES) $(WINDRES) -o $@ -O coff $<

read/%.o: read/%.c
	$(V_CC) $(CC) -c $(OPT) $(CFLAGS) -DWIN32 -Iread -o $@ $<

readtags.exe: $(READTAGS_OBJS) $(READTAGS_HEADS)
	$(V_CC) $(CC) $(OPT) -o $@ $(READTAGS_OBJS) $(LIBS)

clean:
	$(SILENT) echo Cleaning
	$(SILENT) rm -f ctags.exe readtags.exe $(PACKCC)
	$(SILENT) rm -f tags
	$(SILENT) rm -f main/*.o optlib/*.o parsers/*.o parsers/cxx/*.o gnu_regex/*.o fnmatch/*.o misc/packcc/*.o peg/*.o read/*.o win32/*.o win32/mkstemp/*.o
