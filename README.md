## Completely Fair Scheduler
"The Completely Fair Scheduler (CFS) is a process scheduler which was merged into the 2.6.23 (October 2007) release of the Linux kernel and is the default scheduler. It handles CPU resource allocation for executing processes, and aims to maximize overall CPU utilization while also maximizing interactive performance." -Wikipedia 

This is an implementation of the Completely Fair Scheduler which can be found 
[here](https://en.wikipedia.org/wiki/Completely_Fair_Scheduler) and [here](https://www.linuxjournal.com/node/10267). 

This is one of the algorithms used in linux to assign CPU time to processes according to their priority.

## Usage

```
SCHEDULER> (easy-make-task 1)
<     1 , 0.00>
SCHEDULER> (easy-make-task 2)
<     2 , 0.00>
SCHEDULER> (easy-make-task 3)
<     3 , 0.00>
SCHEDULER> (easy-make-task 4)
<     4 , 0.00>
SCHEDULER> (print-tasks)

0 
<     4 , 0.00> 
<     3 , 0.00> 
<     2 , 0.00> 
<     1 , 0.00> 
 0.00
; No value
SCHEDULER> (nice-one-step)

0 
<     3 , -1.00> 
<     2 , -1.00> 
<     1 , -1.00> 
<     4 , 1.50> 
 0.00
; No value
SCHEDULER> (scheduloop 10)


0 
<     2 , -2.00> 
<     1 , -2.00> 
<     4 , 0.50> 
<     3 , 1.33> 
 0.00

0 
<     1 , -3.00> 
<     4 , -0.50> 
<     3 , 0.33> 
<     2 , 2.00> 
 0.00

0 
<     4 , -1.50> 
<     3 , -0.67> 
<     2 , 1.00> 
<     1 , 6.00> 
 0.00

0 
<     3 , -1.67> 
<     4 , 0.00> 
<     2 , 0.00> 
<     1 , 5.00> 
 0.00

0 
<     4 , -1.00> 
<     2 , -1.00> 
<     3 , 0.67> 
<     1 , 4.00> 
 0.00

0 
<     2 , -2.00> 
<     3 , -0.33> 
<     4 , 0.50> 
<     1 , 3.00> 
 0.00

0 
<     3 , -1.33> 
<     4 , -0.50> 
<     2 , 2.00> 
<     1 , 2.00> 
 0.00

0 
<     4 , -1.50> 
<     3 , 1.00> 
<     2 , 1.00> 
<     1 , 1.00> 
 0.00

0 
<     4 , 0.00> 
<     3 , 0.00> 
<     2 , 0.00> 
<     1 , 0.00> 
 0.00

0 
<     3 , -1.00> 
<     2 , -1.00> 
<     1 , -1.00> 
<     4 , 1.50> 
 0.00
 
 SCHEDULER>  (easy-make-task 90)
<    90 , 0.00>
SCHEDULER> (nice-one-step)

0 
<     2 , -11.00> 
<     1 , -11.00> 
<    90 , -1.00> 
<     4 , 14.00> 
<     3 , 22.33> 
 0.00
; No value
SCHEDULER> (nice-one-step)

0 
<     1 , -12.00> 
<    90 , -2.00> 
<     4 , 13.00> 
<     3 , 21.33> 
<     2 , 38.00> 
 0.00
; No value
SCHEDULER> 
```

### Add Tasks

```(scheduler::easy-make-task n)```

### One time step

```(scheduler::one-step)```

### Reset Tasks

```(scheduler::reset-tasks)```

### Print Tasks

```(scheduler::print-tasks)```

### Other

TODO::document the other functions in this file, like `scheduloop`, remove tasks by id, attach data.
