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

// DEBUGGING
//#define DEBUGGING true
#ifdef DEBUGGING
	#define DEBUG( x )  x
#else
	#define DEBUG( x )
#endif
// temporary debug
#define DEBUGX( x )  x

// OPTIONS

int N = 10;
int M = 1000;
int F = 10;
int B = 0;

// USAGE
string USAGE =
"random_spr_walk, version 0.0.1\n";

// FUNCTION PROTOTYPES

// MAIN
//
int main(int argc, char *argv[]) {
	// 1. read input
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
		else if (strcmp(arg, "-niterations") == 0) {
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

	// 2. generate a random tree on N leaves
	Node *T = random_tree(N);
	T->preorder_number();
	if (B <= 0) {
		cout << "0: " << T->str_subtree() << ";" << endl;
	}

	// 3. for M iterations
	for (int i = 1; i <= M; i++) {
		// 4. 	find the SPR neighborhood degree
		int d = count_rspr_neighbors(T);
		DEBUG(cout << d << " neighbors" << endl);

		// 5. 	until done
		bool done = false;
		while (!done) {
			// 6. 		propose a random move
			pair<Node *, Node*> move = random_spr(T);
			DEBUG(cout << "MOVE: " << endl;
			cout << "\t" << move.first->str_subtree() << endl;
			cout << "\t" << move.second->str_subtree() << endl;
			cout << endl;
			)
			int which_sibling = 0;
			Node *undo = move.first->spr(move.second, which_sibling);
			T->post_spr_clean();

			DEBUG(cout << "\tproposed tree: " << T->str_subtree() << endl);
			// 7.			determine T2's neighborhood degree
			int d2 = count_rspr_neighbors(T);
			DEBUG(cout << "\t" << d2 << " neighbors" << endl);

			// 8.			accept with prob max(1, d(T1) / d(T2))
			double accept_prob = (double)d / (double)d2;
			if (accept_prob > 1) {
				accept_prob = 1;
			}
			DEBUG(cout << "\tacceptance probability: " << d << "/" << d2 << " = " << accept_prob << endl);
			double r = (double)rand() / (double)RAND_MAX;
			DEBUG(cout << "\tr = " << r << endl);
			if (r < accept_prob) {
				// 9.		keep the move
				DEBUG(cout << "\taccepted" << endl);
				done = true;
			}
			else {
				// undo the move
				move.first->spr(undo, which_sibling);
				T->post_spr_clean();
				DEBUG(cout << "\trejected" << endl);
			}
			//10.	sample every M trees
			if (i % F == 0) {
				// 11.		output the tree
				cout << i << ": ";
				cout << T->str_subtree() << ";" << endl;
			}
			if (!done) {
				i++;
			}
		}
	}

	// cleanup
	//
	if (T != NULL) {
		T->delete_tree();
	}

	return 0;
}
