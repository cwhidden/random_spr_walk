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


string PROB_FILE = "";
bool DO_TREE_PROB = false;
bool NNI_ONLY = false;
int SEED = -1;
bool GEN_SEED = true;

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
		else if (strcmp(arg, "-tprobs") == 0) {
			if (max_args > argc) {
				char *arg2 = argv[argc+1];
				if (arg2[0] != '-') {
					PROB_FILE = arg2;
					DO_TREE_PROB = true;
				}
			}
		}
		else if (strcmp(arg, "-seed") == 0) {
			if (max_args > argc) {
				char *arg2 = argv[argc+1];
				if (arg2[0] != '-') {
					SEED = atoi(arg2);
					GEN_SEED = false;
				}
			}
		}
		else if (strcmp(arg, "-nni") == 0 ||
					strcmp(arg, "--nni" ) == 0) {
			NNI_ONLY = true;
		}
		else if (strcmp(arg, "--help") == 0) {
			cout << USAGE;
			return 0;
		}
	}

	// initialize random number generator
	// TODO: allow a specific number for repeatability
	if (GEN_SEED) {
		srand(random_device{}());
	}
	else {
		srand(SEED);
	}

	// 1.5 read tree probabilities
	map<string, double> tree_prob = map<string, double>();
	if (DO_TREE_PROB) {
		bool tree_prob_result = read_tree_probabilities(tree_prob, PROB_FILE);
		if (!tree_prob_result) {
			cout << "error reading probabilites from " << PROB_FILE << endl;
			return 1;
		}
		DEBUG(
		else {
			cout << "read " << tree_prob.size() << " trees" << endl;
			cout << tree_prob.begin()->first << endl;
		}
		)
	}

	// 2. generate a random tree on N leaves
	Node *T = random_tree(N);
	T->normalize_order();
	T->post_spr_clean();
	if (B <= 0) {
		cout << "0: " << T->str_subtree() << ";" << endl;
	}

	// 3. for M iterations
	for (int i = 1; i <= M; i++) {
		// 4. 	find the SPR neighborhood degree
		int d;
		if (NNI_ONLY) {
			d = count_nni_neighbors(N);
		}
		else {
			d = count_rspr_neighbors(T);
		}
		double logl = 1;
		if (DO_TREE_PROB) {
				logl = tree_prob[normalized_str_subtree(T)];
		}
		DEBUG(cout << d << " neighbors" << endl);

		// 5. 	until done
		bool done = false;
		while (!done && i <= M) {
			// 6. 		propose a random move
			pair<Node *, Node*> move;
			if (NNI_ONLY) {
				move = random_nni(T, N);
			}
			else {
				move = random_spr(T);
			}
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
			int d2;
			if (NNI_ONLY) {
				d2 = count_nni_neighbors(N);
			}
			else {
				d2 = count_rspr_neighbors(T);
			}
			double logl2 = 1;
			if (DO_TREE_PROB) {
				logl2 = tree_prob[normalized_str_subtree(T)];
			}
			DEBUG(cout << "\t" << d2 << " neighbors" << endl);

			// 8.			accept with prob min(1, d(T1) / d(T2)):
            // MH ratio for proposing a move from T1 to T2 is
            // min[1, (P(T2) / P(T1))  (g(T2 -> T1) / g(T1 -> T2))]
            // In our case,
            // g(T2 -> T1) = 1/d(T2) and
            // g(T1 -> T2) = 1/d(T1)
			double accept_prob = log((double)d / (double)d2);
			if (DO_TREE_PROB) {
				accept_prob += logl2 - logl;
			}
			if (accept_prob > log(1)) {
				accept_prob = log(1);
			}
			DEBUG(
					cout << "\tacceptance probability: ";
						cout << d << "/" << d2 << " * ";
						if (DO_TREE_PROB) {
							cout << logl2 << "/" << logl;
						}
						cout << " = " << accept_prob << endl
			);
			double r = (double)rand() / (double)RAND_MAX;
			DEBUG(cout << "\tr = " << r << endl);
			if (log(r) < accept_prob) {
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
			//10.	sample every F trees
			if (i % F == 0) {
				// 11.		output the tree
				cout << i << ": ";
				T->normalize_order();
				T->preorder_number();
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
