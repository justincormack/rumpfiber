INCLUDE=-I./rump/include/ -I./buildrump.sh/src/tools/compat
WARN=-Wall -Wstrict-prototypes -Wmissing-prototypes -Wpointer-arith -Wno-sign-compare  -Wno-traditional  -Wa,--fatal-warnings -Wreturn-type -Wswitch -Wshadow -Wcast-qual -Wwrite-strings -Wextra -Wno-unused-parameter -Wno-sign-compare -Wold-style-definition -Wsign-compare -Wformat=2   -Wno-format-zero-length  -Werror
CFLAGS=${INCLUDE} -O2 -g -fPIC -std=gnu99 ${WARN} -DLIBRUMPUSER -D_REENTRANT  -c -DGPROF -DPROF
SRCDIR=./buildrump.sh/src/lib/librumpuser
SOURCES=rumpuser_bio.c rumpuser_component.c rumpuser_dl.c rumpuser_pth.c rumpuser_sp.c rumpuser.c rumpuser_daemonize.c rumpuser_errtrans.c
OBJECTS=$(SOURCES:.c=.o)
DOTA=librumpuser.a
SOLIBS=-lpthread -lrt -ldl
SONAME=librumpuser.so.0
TARGET=librumpuser.so.0.1


default:	all

all:		rump ${TARGET}

rump:		
		./buildrump.sh/buildrump.sh -d ./rump -o ./buildrump.sh/obj -s ./buildrump.sh/src checkout fullbuild

%.o:		${SRCDIR}/%.c rump
		${CC} $< ${CFLAGS} -o $@

${DOTA}:	${OBJECTS}
		${AR} rcs ${DOTA} ${OBJECTS}

${TARGET}:	${DOTA}
		${CC} -Wl,-x -shared -Wl,-soname,${SONAME} -Wl,--warn-shared-textrel -o ${TARGET} -Wl,--whole-archive ${DOTA} -Wl,--no-whole-archive ${SOLIBS}

clean:		
		rm -rf ${OBJECTS} ${DOTA} ${TARGET} rump *~

