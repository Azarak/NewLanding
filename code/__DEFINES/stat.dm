/*
	Used with the various stat variables (mob, machines)
*/

//mob/var/stat things
#define CONSCIOUS 0
#define UNCONSCIOUS 1
#define DEAD 2

//mob/var/shock_stat things
#define SHOCK_NONE 0
#define SHOCK_MILD 1
#define SHOCK_SEVERE 2

#define SHOCK_CONDITION "shock"

//Maximum healthiness an individual can have
#define MAX_SATIETY 600

// bitflags for machine stat variable
#define BROKEN (1<<0)
#define NOPOWER (1<<1)
#define MAINT (1<<2) // under maintaince
#define EMPED (1<<3) // temporary broken by EMP pulse

//ai power requirement defines
#define POWER_REQ_ALL 1
