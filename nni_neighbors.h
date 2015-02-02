#ifndef INCLUDE_NNI_NEIGHBORS
#define INCLUDE_NNI_NEIGHBORS

// INCLUDES
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

#include "Forest.h"
#include "LCA.h"

using namespace std;

// FUNCTIONS

list<Node *> get_nni_neighbors(Node *tree);
list<Node *> get_nni_neighbors(Node *tree, set<string> &known_trees);
void get_nni_neighbors(Node *n, Node *root, list<Node *> &neighbors, set<string> &known_trees);
void get_nni_neighbors(Node *n, Node *new_sibling, Node *root, list<Node *> &neighbors, set<string> &known_trees);
void add_nni_neighbor(Node *n, Node *new_sibling, Node *root, list<Node *> &neighbors, set<string> &known_trees);

list<Node *> get_nni_neighbors(Node *tree) {
	set<string> known_trees = set<string>();
	return get_nni_neighbors(tree, known_trees);
}

// get a list of a trees neighbors
list<Node *> get_nni_neighbors(Node *tree, set<string> &known_trees) {
	list<Node *> neighbors = list<Node *>();
	get_nni_neighbors(tree, tree, neighbors, known_trees);
	return neighbors;
}

/* consider choices of subtree source and target
   there are four possible targets:
	   1. aunt - equivalent to moving neighbor to grandparent
		 2. grandparent
		 3. left niece - equivalent to moving same up here
		 4. right niece - equivalent to moving same up here
	 so we consider 2 for each subtree in the tree
*/
void get_nni_neighbors(Node *n, Node *root, list<Node *> &neighbors, set<string> &known_trees) {

	// recurse on sources
	if (n->lchild() != NULL) {
		get_nni_neighbors(n->lchild(), root, neighbors, known_trees);
	}
	if (n->rchild() != NULL) {
		get_nni_neighbors(n->rchild(), root, neighbors, known_trees);
	}

	if (n->parent() != NULL && n->parent()->parent() != NULL) {
		add_nni_neighbor(n, n->parent()->parent(), root, neighbors, known_trees);
	}
}

void add_nni_neighbor(Node *n, Node *new_sibling, Node *root, list<Node *> &neighbors, set<string> &known_trees) {

	if (n->parent() != NULL &&
			(new_sibling == n->parent())) {
		return;
	}
	if (new_sibling == n) {
		return;
	}
	Node *old_sibling = n->get_sibling();
	int which_sibling = 0;
	//cout << "original: " << root->str_subtree() << endl;
	Node *undo = n->spr(new_sibling, which_sibling);

	string name = root->str_subtree();
	// quick check for obvious duplicate
	set<string>::iterator x = known_trees.find(name);
	if (x == known_trees.end()) {
		Node *new_tree = build_tree(name);
		// normalize and check again
		new_tree->normalize_order();
		name = new_tree->str_subtree();
		x = known_trees.find(name);
		if (x == known_trees.end()) {
			known_trees.insert(name);
			neighbors.push_back(new_tree);
		}
		else {
			new_tree->delete_tree();
		}
		//cout << "proposed tree: " << new_tree->str_subtree() << endl;
	}



	n->spr(undo, which_sibling);
	//cout << "reverted: " << root->str_subtree() << endl;
	//cout << endl;
}


#endif
