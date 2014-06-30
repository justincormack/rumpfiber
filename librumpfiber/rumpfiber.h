
#include <stdint.h>
#include <ucontext.h>
#include <time.h>
#include <unistd.h>
#include <string.h>

#include "queue.h"

static void printk(const char *s);

static void
printk(const char *msg)
{
	int ret __attribute__((unused));

	ret = write(2, msg, strlen(msg));
}

struct thread {
    char *name;
    void *lwp;
    void *cookie;
    int64_t wakeup_time;
    TAILQ_ENTRY(thread) thread_list;
    ucontext_t ctx;
    uint32_t flags;
    int threrrno;
};

void idle_thread_fn(void *unused);

int is_runnable(struct thread *);
void set_runnable(struct thread *);
void clear_runnable(struct thread *);

#define RUNNABLE_FLAG   0x00000001
#define THREAD_MUSTJOIN 0x00000002
#define THREAD_JOINED   0x00000004
#define THREAD_EXTSTACK 0x00000008
#define THREAD_TIMEDOUT 0x00000010

#define STACKSIZE 65536

void init_sched(void);
void set_sched_hook(void (*f)(void *, void *));
struct thread *init_mainthread(void *);
void run_idle_thread(void);
struct thread* create_thread(const char *name, void *cookie,
			     void (*f)(void *), void *data,
			     void *stack, size_t stack_size);
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
int abssleep_real(uint64_t millisecs);

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

/* compatibility */
#ifndef HAVE_CLOCK_NANOSLEEP
static int clock_nanosleep(clockid_t clock_id, int flags,
	const struct timespec *request, struct timespec *remain);
static int
clock_nanosleep(clockid_t clock_id, int flags,
	const struct timespec *request, struct timespec *remain)
{

	assert(flags == 0);
	return nanosleep(request, remain);
}
#endif

