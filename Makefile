CC=g++
CC64=CC
CFLAGS=-O2 -std=c++0x -march=native
OMPFLAGS=-fopenmp
C64FLAGS=$(CFLAGS)
BOOST_GRAPH=-lboost_graph-mt
BOOST_ANY=-L/lib/libboost*
LFLAGS=#$(BOOST_GRAPH) $(BOOST_ANY)
DEBUGFLAGS=-g -O0 -std=c++0x
PROFILEFLAGS=-pg
OBJS=random_spr_walk
all: $(OBJS)

random_spr_walk: random_spr_walk.cpp *.h
	$(CC) $(CFLAGS) -o random_spr_walk random_spr_walk.cpp

.PHONY: debug
.PHONY: profile
.PHONY: test

debug:
	$(CC) $(LFLAGS) $(DEBUGFLAGS) -o random_spr_walk random_spr_walk.cpp
profile:
	$(CC) $(LFLAGS) $(DEBUGFLAGS) $(PROFILEFLAGS) -o random_spr_walk random_spr_walk.cpp
test:
	./random_spr_walk  -ntax 10 -sfreq 2 -nsamples 10
