#ifndef INCLUDE_SPR_NEIGHBORS
#define INCLUDE_SPR_NEIGHBORS

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

list<Node *> get_neighbors(Node *tree);
list<Node *> get_neighbors(Node *tree, set<string> &known_trees);
void get_neighbors(Node *n, Node *root, list<Node *> &neighbors, set<string> &known_trees);
void get_neighbors(Node *n, Node *new_sibling, Node *root, list<Node *> &neighbors, set<string> &known_trees);
void add_neighbor(Node *n, Node *new_sibling, Node *root, list<Node *> &neighbors, set<string> &known_trees);

list<Node *> get_neighbors(Node *tree) {
	set<string> known_trees = set<string>();
	return get_neighbors(tree, known_trees);
}

// get a list of a trees neighbors
list<Node *> get_neighbors(Node *tree, set<string> &known_trees) {
	list<Node *> neighbors = list<Node *>();
	get_neighbors(tree, tree, neighbors, known_trees);
	return neighbors;
}

// consider choices of subtree source
void get_neighbors(Node *n, Node *root, list<Node *> &neighbors, set<string> &known_trees) {

	// recurse
	if (n->lchild() != NULL) {
		get_neighbors(n->lchild(), root, neighbors, known_trees);
	}
	if (n->rchild() != NULL) {
		get_neighbors(n->rchild(), root, neighbors, known_trees);
	}

	get_neighbors(n, root, root, neighbors, known_trees);
}

// consider choices of subtree target
void get_neighbors(Node *n, Node *new_sibling, Node *root, list<Node *> &neighbors, set<string> &known_trees) {
	if (n == new_sibling) {
		return;
	}
	// recurse
	if (new_sibling->lchild() != NULL) {
		get_neighbors(n, new_sibling->lchild(), root, neighbors, known_trees);
	}
	if (new_sibling->rchild() != NULL) {
		get_neighbors(n, new_sibling->rchild(), root, neighbors, known_trees);
	}

	add_neighbor(n, new_sibling, root, neighbors, known_trees);

}

void add_neighbor(Node *n, Node *new_sibling, Node *root, list<Node *> &neighbors, set<string> &known_trees) {

	// check for obvious duplicates
	if (n->parent() != NULL &&
			(new_sibling == n->parent())) {
	// cout << "rule 1" << endl;
		return;
	}
	if (n->parent() != NULL &&
			new_sibling->parent() != NULL &&
			n->parent()->parent() == new_sibling->parent()) {
//		cout << "rule 2" << endl;
		return;
	}
	if (new_sibling == n->get_sibling()) {
//		cout << "rule 3" << endl;
		return;
	}
//		cout << "foo3" << endl;
//	cout << "foo4" << endl;
	if (new_sibling == n) {
//		cout << "rule 4" << endl;
		return;
	}
	Node *old_sibling = n->get_sibling();
	//if (new_sibling != old_sibling)
	//
	int which_sibling = 0;
//	cout << "original: " << root->str_subtree() << endl;
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
	}
//	cout << "proposed tree: " << new_tree->str_subtree() << endl;



	n->spr(undo, which_sibling);
//	cout << "reverted: " << root->str_subtree() << endl;
//	cout << endl;
}


#endif
