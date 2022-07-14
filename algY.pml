#define MutexDontCare
#include "critical2.h"

// b[0] = P's intent to enter critical section.
// b[1] = Q's intent to enter critical section.
bit b[2]

proctype P() {
    do
    :: true ->
        non_critical_section();
        b[0] = true;
        do
        :: b[1] == true ->
            b[0] = true;
            do
            :: b[0] != true ->
                waitP: skip
            :: else -> break
            od
            b[0] = true;
        :: else -> break
        od
        csP: critical_section();
        b[0] = false;
    od
}

proctype Q() {
    do
    :: true ->
        non_critical_section();
        b[1] = true;
        do
        :: b[0] == true ->
            b[1] = false;
            do
            :: b[0] != false ->
                waitQ: skip
            :: else -> break
            od
            b[1] = true;
        :: else -> break
        od
        csQ: critical_section();
        b[1] = false;
    od
}

init {
    run P();
    run Q();
}

// Check mutual exclusion.
ltl mutexPQ { [] !(P@csP && Q@csQ) }

// Check eventual entry.
ltl entryP { [] (P@waitP implies (<> P@csP)) }
ltl entryQ { [] (Q@waitQ implies (<> Q@csQ)) }

// Check absence of deadlock.
ltl deadlock1 { <>[] !(P@waitP && Q@csQ) }
ltl deadlock2 { <>[] !(P@waitP && Q@waitQ) }
ltl deadlock3 { <>[] !(P@csP && Q@waitQ) }
ltl deadlock4 { <>[] !(P@csP && Q@csQ) }

// Check absence of unnecessary delay.
ltl delayP { [] ((P@waitP && []!Q@csQ && b[0]) implies (<> P@csP)) }
ltl delayQ { [] ((Q@waitQ && []!P@csP && b[1]) implies (<> Q@csQ)) }
