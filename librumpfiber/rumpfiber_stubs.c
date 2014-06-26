#include <stdlib.h>

#include "rumpfiber_thread.h"

int ohcrap(void);
int ohcrap(void) {printk("rumphyper: unimplemented stub\n"); exit(1);}

int nothing(void);
int nothing(void) {return 0;}

#define TIMETOPANIC(name) \
int name(void) __attribute__((alias("ohcrap")));

#define NOTHING(name) \
int name(void) __attribute__((alias("nothing")));

/* sp not supported */
NOTHING(rumpuser_sp_init);
NOTHING(rumpuser_sp_fini);
TIMETOPANIC(rumpuser_sp_raise);
TIMETOPANIC(rumpuser_sp_copyin);
TIMETOPANIC(rumpuser_sp_copyout);
TIMETOPANIC(rumpuser_sp_copyinstr);
TIMETOPANIC(rumpuser_sp_copyoutstr);
TIMETOPANIC(rumpuser_sp_anonmmap);

/* bio not done yet */
TIMETOPANIC(rumpuser_bio)
