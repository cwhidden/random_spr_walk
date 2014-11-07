#include <cstdio>
#include <cstdlib>
#include <ctime>
#include <string>
#include <cstring>
#include <iostream>
#include <fstream>
#include <sstream>
#include <climits>
#include <vector>
#include <map>
#include <utility>
#include <algorithm>
#include <list>
#include <time.h>
#include <random>

#include "Forest.h"
#include "LCA.h"
#include "spr_neighbors.h"
#include "random_spr_walk.h"

using namespace std;

// OPTIONS

int N = 10;
int M = 1000;
int F = 10;

// USAGE
string USAGE =
"random_spr_walk, version 0.0.1\n";

// FUNCTION PROTOTYPES

// MAIN
//
int main(int argc, char *argv[]) {
	int max_args = argc-1;
	while (argc > 1) {
		char *arg = argv[--argc];

		if (strcmp(arg, "-ntax") == 0) {
			if (max_args > argc) {
				char *arg2 = argv[argc+1];
				if (arg2[0] != '-') {
					N = atoi(arg2);
				}
			}
		}
		else if (strcmp(arg, "-sfreq") == 0) {
			if (max_args > argc) {
				char *arg2 = argv[argc+1];
				if (arg2[0] != '-') {
					F = atoi(arg2);
				}
			}
		}
		else if (strcmp(arg, "-nsamples") == 0) {
			if (max_args > argc) {
				char *arg2 = argv[argc+1];
				if (arg2[0] != '-') {
					M = atoi(arg2);
				}
			}
		}
		else if (strcmp(arg, "--help") == 0) {
			cout << USAGE;
			return 0;
		}
	}

	// initialize random number generator
	// TODO: allow a specific number for repeatability
	srand(random_device{}());

	// current tree
	Node *T = random_tree(N);
	cout << T->str_subtree() << endl;

	// cleanup
	//
	if (T != NULL) {
		T->delete_tree();
	}

	return 0;
}

// input: number of taxa, number of iterations, sampling frequency
//
// 1. read input
// 2. generate a random tree on n leaves
// 3. for m iterations
// 4. 	find the SPR neighborhood (degree)
// 5. 	until done
// 6. 		propose a random move
// 7.			determine T2's neighborhood degree
// 8.			accept with prob max(1, d(T1) / d(T2))
// 9.		apply the move
// 10.	if m % f == 0
// 11.		output the tree
