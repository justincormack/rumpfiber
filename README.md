librumpfiber [![Build Status](https://travis-ci.org/rumpkernel/rumpfiber.png?branch=master)](https://travis-ci.org/rumpkernel/rumpfiber)
============

A [rump kernel](http://rumpkernel.org) hypercall library based on fibers (userspace threads, using swapcontext) rather than pthreads.

This repository is obsolete, the code is now merged into the standard Posix hypercall implementation upstream in NetBSD as an option.

To build this option use `./buildrump.sh -V RUMPUSER_THREADS=fiber -V RUMP_CURLWP=hypercall` using the [buildrump.sh](http://repo.rumpkernel.org/buildrump.sh) repository.
