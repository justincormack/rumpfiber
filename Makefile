INCLUDE=-Ilibrumpfiber -I./rump/include/ -I./buildrump.sh/src/tools/compat
WARN=-Wall -Wstrict-prototypes -Wmissing-prototypes -Wpointer-arith -Wa,--fatal-warnings -Wreturn-type -Wswitch -Wshadow -Wcast-qual -Wwrite-strings -Wextra -Wno-unused-parameter -Wold-style-definition -Wsign-compare -Wformat=2 -Werror
CFLAGS+=${INCLUDE} -O2 -g -std=gnu99 ${WARN} -DLIBRUMPUSER
SRCDIR=./librumpfiber
SOURCES=rumpfiber.c rumpfiber_stubs.c rumpuser_component.c rumpuser_dl.c rumpuser_file.c rumpuser_errtrans.c rumpuser_daemonize.c rumpuser_sigtrans.c
OBJECTS=$(SOURCES:%.c=obj/%.o)
PICOBJECTS=$(SOURCES:%.c=obj/%.pico)
DOTA=rump/lib/librumpuser.a
PICA=obj/librumpuser_pic.a
SONAME=librumpuser.so.0
LIBDIR=${PWD}/rump/lib
SHLIB=librumpuser.so.0.1
SYM1=${SONAME}
SYM2=librumpuser.so
SHLIBDIR=${LIBDIR}/${SHLIB}
TARGET=${SHLIBDIR} ${DOTA}
BUILDRUMP=buildrump.sh/buildrump.sh
RUMPLIBS=rump/lib/librump.so
# Linux, -lrt not required on recent versions
SOLIBS=-ldl -lrt
# NetBSD
#SOLIBS=

default:	all

all:		${TARGET}

${BUILDRUMP}:	
		git submodule update --init --recursive

${RUMPLIBS}:	${BUILDRUMP}
		./buildrump.sh/buildrump.sh -qq -d ./rump -o ./buildrump.sh/obj -s ./buildrump.sh/src -k -V RUMP_CURLWP=hypercall -V RUMP_LOCKS_UP=yes checkout fullbuild

obj/%.o:	${SRCDIR}/%.c ${RUMPLIBS}
		mkdir -p obj
		${CC} -c $< ${CFLAGS} -o $@

obj/%.pico:	${SRCDIR}/%.c ${RUMPLIBS}
		mkdir -p obj
		${CC} -c $< ${CFLAGS} -fPIC -o $@

${DOTA}:	${OBJECTS} ${RUMPLIBS} cleana
		${AR} rc $@ ${OBJECTS}
		ranlib $@

${PICA}:	${PICOBJECTS} ${RUMPLIBS} cleana
		${AR} rc $@ ${PICOBJECTS}
		ranlib $@

${SHLIBDIR}:	${PICA}
		${CC} ${LDFLAGS} -Wl,-x -shared -Wl,-soname,${SONAME} -Wl,--warn-shared-textrel -o ${SHLIBDIR} -Wl,--whole-archive ${PICA} -Wl,--no-whole-archive ${SOLIBS}
		rm -f rump/lib/${SYM1} rump/lib/${SYM2}
		ln -s ${SHLIB} rump/lib/${SYM1}
		ln -s ${SHLIB} rump/lib/${SYM2}

ljsyscall:
		git clone https://github.com/justincormack/ljsyscall.git

test: ljsyscall
		( cd ljsyscall && LD_LIBRARY_PATH=../rump/lib luajit test/test.lua rump )

.PHONY: cleana
cleana:
		rm -f ${DOTA} ${PICA}
		rm -rf ljsyscall

.PHONY: clean
clean:		
		rm -rf ${OBJECTS} ${PICOBJECTS} ${PICA} ${TARGET} *~ obj

.PHONY: cleanrump
cleanrump:	clean
		rm -rf rump buildrump.sh/obj
