#	$OpenBSD: Makefile,v 1.9 2014/01/13 01:41:00 tedu Exp $
#
# Copyright 2015 Nathan Holstein

SRCS=	parse.y doas.c

PROG=	doas
MAN=	doas.1 doas.conf.5

BINOWN= root
BINGRP= wheel
BINMODE=4511

COPTS+= -Wall -Wextra -Werror -pedantic -std=c11
CFLAGS+= -I${CURDIR} -I${CURDIR}/libopenbsd ${COPTS}

BINDIR?=/usr/bin
MANDIR?=/usr/share/man

default: ${PROG}

OPENBSD:=reallocarray.c strtonum.c execvpe.c setresuid.c \
	auth_userokay.c setusercontext.c
OPENBSD:=$(addprefix libopenbsd/,${OPENBSD:.c=.o})
libopenbsd.a: ${OPENBSD}
	${AR} -r $@ $?

OBJS:=${SRCS:.y=.c}
OBJS:=${OBJS:.c=.o}

${PROG}: ${OBJS} libopenbsd.a
	${CC} ${CFLAGS} ${LDFLAGS} $^ -o $@

.%.chmod: %
	cp $< $@
	chmod ${BINMODE} $@
	chown ${BINOWN}:${BINGRP} $@

${BINDIR}/${PROG}: .${PROG}.chmod
	mv $< $@

install: ${BINDIR}/${PROG}

clean:
	rm -f libopenbsd.a
	rm -f ${OPENBSD}
	rm -f ${OBJS}
	rm -f ${PROG}

.PHONY: default clean install
.INTERMEDIATE: .${PROG}.chmod
