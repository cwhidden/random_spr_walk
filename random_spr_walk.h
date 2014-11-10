// FUNCTION PROTOTYPES

string itos(int i);
Node *random_tree(int N);

// build a random tree with N leaves
Node *random_tree(int N) {
	Node *T;
	if (N < 3) {
		return NULL;
	}

	// pick starting shape
	int r = rand();
	stringstream ss;
	if (r % 3 == 0) {
		ss << "(0,(1,2))";
	}
	else if (r % 3 == 1) {
		ss << "((0,2),1)";
	}
	else {
		ss << "((0,1),2)";
	}
	T = build_tree(ss.str());

	for (int i = 3; i < N; i++) {
		// 	pick random node
		vector<Node *> nodes = T->find_descendants();
		nodes.push_back(T);
		r = rand() % nodes.size();
		Node *new_sibling = nodes[r];
		// 	expand parent edge
		Node *new_node = new_sibling->expand_parent_edge(new_sibling);
		// 	add new leaf
		new_node->add_child(new Node(itos(i)));
	}
	return T;
}

// determine the number of SPR neighbors of a given rooted tree
// O(N) running time, where N is the number of leaves
// several SPRs result in the same tree, including:
// 1. moving a subtree to its aunt
// 2. moving a subtree to its grandmother
// 3. moving the aunt to the subtree's sibling
// we can avoid this by ignoring 1. and 2. moves
// moreover, moving a subtree to its sibling or parent gives the original topology
// this gives 4 ignored moves per subtree (2 for subtrees at depth 1)
// the number of moves for a subtree with k descendant nodes is thus:
// max(0, 2n-1-k-4)
// ( max(0, 2n-1-k-2) for depth 1 nodes)
int num_rspr_neighbors(Node *T) { 
}

string itos(int i) {
	stringstream ss;
	string a;
	ss << i;
	a = ss.str();
	return a;
}

