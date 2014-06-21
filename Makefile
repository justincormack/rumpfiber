INCLUDE=-I./rump/include/ -I./buildrump.sh/src/tools/compat
WARN=-Wall -Wstrict-prototypes -Wmissing-prototypes -Wpointer-arith -Wno-sign-compare  -Wno-traditional  -Wa,--fatal-warnings -Wreturn-type -Wswitch -Wshadow -Wcast-qual -Wwrite-strings -Wextra -Wno-unused-parameter -Wno-sign-compare -Wold-style-definition -Wsign-compare -Wformat=2   -Wno-format-zero-length  -Werror
CFLAGS=${INCLUDE} -O0 -g -fPIC -std=gnu99 ${WARN} -DLIBRUMPUSER -D_REENTRANT  -c -DGPROF -DPROF
SRCDIR=./librumpfiber
SOURCES=rumpfiber.c rumpfiber_thread.c rumpfiber_synch.c rumpuser_component.c rumpuser_dl.c rumpuser_errtrans.c rumpuser_sigtrans.c
OBJECTS=$(SOURCES:%.c=obj/%.o)
PICOBJECTS=$(SOURCES:%.c=obj/%.pico)
DOTA=rump/lib/librumpuser.a
PICA=obj/librumpuser_pic.a
SOLIBS=-lrt -ldl
SONAME=librumpuser.so.0
SHLIB=rump/lib/librumpuser.so.0.1
TARGET=${SHLIB} ${DOTA}
BUILDRUMP=buildrump.sh/buildrump.sh
RUMPLIBS=rump/lib/librump.so

default:	all

all:		${TARGET}

${BUILDRUMP}:	
		git submodule update --init --recursive

${RUMPLIBS}:	${BUILDRUMP}
		./buildrump.sh/buildrump.sh -d ./rump -o ./buildrump.sh/obj -s ./buildrump.sh/src -k checkout fullbuild

obj/%.o:	${SRCDIR}/%.c ${RUMPLIBS}
		mkdir -p obj
		${CC} $< ${CFLAGS} -o $@

obj/%.pico:	${SRCDIR}/%.c ${RUMPLIBS}
		mkdir -p obj
		${CC} $< ${CFLAGS} -fPIC -o $@

${DOTA}:	${OBJECTS} ${RUMPLIBS} cleana
		${AR} rc $@ ${OBJECTS}
		ranlib $@

${PICA}:	${PICOBJECTS} ${RUMPLIBS} cleana
		${AR} rc $@ ${PICOBJECTS}
		ranlib $@

${SHLIB}:	${PICA}
		${CC} -Wl,-x -shared -Wl,-soname,${SONAME} -Wl,--warn-shared-textrel -o ${SHLIB} -Wl,--whole-archive ${PICA} -Wl,--no-whole-archive ${SOLIBS}

.PHONY: cleana
cleana:
		rm -f ${DOTA} ${PICA}

.PHONY: clean
clean:		
		rm -rf ${OBJECTS} ${PICOBJECTS} ${PICA} ${TARGET} *~ obj

.PHONY: cleanrump
cleanrump:	clean
		rm -rf rump
