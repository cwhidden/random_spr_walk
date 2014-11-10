// DEBUGGING
//#define DEBUGGING true
#ifdef DEBUGGING
	#define DEBUG( x )  x
#else
	#define DEBUG( x )
#endif
// temporary debug
#define DEBUGX( x )  x

// FUNCTION PROTOTYPES

string itos(int i);
Node *random_tree(int N);
int count_rspr_neighbors(Node *T);
int count_rspr_neighbors_hlpr(Node *T, int total, vector<int> &descendant_counts);
pair<Node *, Node*> random_spr(Node *T);
int random_spr_hlpr(Node *T, Node *n, int total, vector<int> &descendant_counts, int r, Node **source, Node **target);
void select_neighbor(Node *T, Node *n, int r, Node **source, Node **target);
int select_neighbor_hlpr(Node *n, int r, Node **source, Node **target);
bool exclude_target(Node *s, Node *t);

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
	T->normalize_order();
	T->set_depth(0);
	T->fix_depths();
	T->preorder_number();
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
int count_rspr_neighbors(Node *T) { 
	// vector of descendants per node indexed by preorder number
	vector<int> *descendant_counts = T->find_descendant_counts();
	int total = (*descendant_counts)[T->get_preorder_number()] + 1;
	DEBUG(cout << "T: " << total << endl);
	int num_neighbors = count_rspr_neighbors_hlpr(T, total, *descendant_counts);

	// cleanup
	delete descendant_counts;

	return num_neighbors;

}

int count_rspr_neighbors_hlpr(Node *T, int total, vector<int> &descendant_counts) {
	int num_neighbors = total - (descendant_counts[T->get_preorder_number()] + 1) - 4;
	// correction for depth 1 nodes
	if (T->get_depth() == 1) {
		num_neighbors += 2;
	}
	if (num_neighbors < 0) {
		num_neighbors = 0;
	}
	DEBUG(cout << "n: " << num_neighbors << "\t" << T->str_subtree() << endl);
	// moves from children
	for (Node *c : T->get_children()) {
		num_neighbors += count_rspr_neighbors_hlpr(c, total, descendant_counts);
	}
	return num_neighbors;
}

// select a random neighbor of T
//
// apply the same logic as count_rspr_neighbors to select a random neighbor in
// O(n) time
pair<Node *, Node*> random_spr(Node *T) {
	int num_neighbors = count_rspr_neighbors(T);
	vector<int> *descendant_counts = T->find_descendant_counts();
	int total = (*descendant_counts)[T->get_preorder_number()] + 1;
	int r = (rand() % num_neighbors) + 1;
	Node *source;
	Node *target;
	random_spr_hlpr(T, T, total, *descendant_counts, r, &source, &target);
	return make_pair(source, target);
}


int random_spr_hlpr(Node *T, Node *n, int total, vector<int> &descendant_counts, int r, Node **source, Node **target) {
	DEBUG(cout << "random_spr_hlpr(" << r << ")" << endl);
	int num_neighbors = total - (descendant_counts[n->get_preorder_number()] + 1) - 4;
	// correction for depth 1 nodes
	if (n->get_depth() == 1) {
		num_neighbors += 2;
	}
	if (num_neighbors < 0) {
		num_neighbors = 0;
	}

	DEBUG(cout << "\t" << n->str_subtree() << endl);
	DEBUG(cout << "\tnn=" << num_neighbors << endl);

	if (r <= num_neighbors) {
		select_neighbor(T, n, r, source, target);
		return -1;
	}
	else {
		r -= num_neighbors; 
	}
	for (Node *c : n->get_children()) {
		r = random_spr_hlpr(T, c, total, descendant_counts, r, source, target);
		if (r <= 0) {
			break;
		}
	}
	return r;
}

void select_neighbor(Node *T, Node *n, int r, Node **source, Node **target) {
	*source = n;
	select_neighbor_hlpr(T, r, source, target);
}

int select_neighbor_hlpr(Node *n, int r, Node **source, Node **target) {
	DEBUG(cout << "select_neighbor_hlpr(" << r << ")" << endl);
	DEBUG(cout << n->str_subtree() << endl);
	if(n == *source) {
		return r;
	}

	if (!exclude_target(*source, n)) {
		r--;
	}
	if (r == 0) {
		*target = n;
		return -1;
	}
	for (Node *c : n->get_children()) {
		r = select_neighbor_hlpr(c, r, source, target);
		if (r <= 0) {
			return r;
		}
	}
	return r;
}

// ignore duplicate moves, as discussed above
// 1. moving a subtree to its aunt
// 2. moving a subtree to its grandmother
// 3. moving a subtree to its sibling
// 4. moving a subtree to its parent
bool exclude_target(Node *s, Node *t) {
	if (s->parent() == NULL) {
		return true;
	}
	// 1.
	if (s->parent()->parent() == t->parent()) {
		return true;
	}
	// 2.
	if (s->parent()->parent() == t) {
		return true;
	}
	// 3.
	if (s->parent() == t->parent()) {
		return true;
	}
	// 4.
	if (s->parent() == t) {
		return true;
	}
	return false;
}

string itos(int i) {
	stringstream ss;
	string a;
	ss << i;
	a = ss.str();
	return a;
}

