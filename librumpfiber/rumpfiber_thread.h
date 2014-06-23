
#include <stdint.h>
#include <stdio.h>
#include <ucontext.h>
#include <time.h>

#include "queue.h"

#define printk(...) fprintf(stderr, __VA_ARGS__)

struct thread {
    char *name;
    void *lwp;
    int64_t wakeup_time;
    TAILQ_ENTRY(thread) thread_list;
    ucontext_t ctx;
    uint32_t flags;
    int threrrno;
};

extern struct thread *idle_thread;
void idle_thread_fn(void *unused);

#define RUNNABLE_FLAG   0x00000001
#define THREAD_MUSTJOIN 0x00000002
#define THREAD_JOINED   0x00000004

#define is_runnable(_thread)    (_thread->flags & RUNNABLE_FLAG)
#define set_runnable(_thread)   (_thread->flags |= RUNNABLE_FLAG)
#define clear_runnable(_thread) (_thread->flags &= ~RUNNABLE_FLAG)

#define STACKSIZE 65536

void init_sched(void);
void run_idle_thread(void);
struct thread* create_thread(const char *name, void (*f)(void *), void *data);
void exit_thread(void) __attribute__((noreturn));
void join_thread(struct thread *);
void schedule(void);
void switch_threads(struct thread *prev, struct thread *next);
void run_idle_thread(void);
struct thread *get_current(void);
int64_t now(void);
void setcurrentthread(const char *name);
void wake(struct thread *thread);
void block(struct thread *thread);
void msleep(uint64_t millisecs);
void abssleep(uint64_t millisecs);

/* compatibility, replace with some sort of configure system */

#ifdef __NetBSD__
#include <sys/cdefs.h>
#include <sys/param.h>
#if __NetBSD_Prereq__(6,99,16)
#define HAVE_CLOCK_NANOSLEEP
#endif
#endif

#if (defined(__linux__) && !defined(__ANDROID__)) || defined(__sun__)
#define HAVE_CLOCK_NANOSLEEP
#endif

#ifndef HAVE_CLOCK_NANOSLEEP
int clock_nanosleep(clockid_t clock_id, int flags,
	const struct timespec *request, struct timespec *remain);
#endif

