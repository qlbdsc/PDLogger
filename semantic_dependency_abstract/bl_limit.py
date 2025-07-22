import pygraphviz as pgv
import subprocess, os, argparse

# Set up argument parser
parser = argparse.ArgumentParser()
parser.add_argument('-n', "--number", type=int, help="target node number", default=1)
parser.add_argument('-d', "--dotfile", type=str, help="path to DOT file", default=0)
args = parser.parse_args()

def load_pdg(dot_file):
    """ Load the PDG (DOT file) and return a graph object """
    graph = pgv.AGraph(dot_file)
    return graph

def backward_slice_with_labels(graph, target_node, max_hops=7):
    """
    Perform backward slicing from the target node (up to max_hops levels),
    and collect labels for each node in the slice.
    """
    visited = set()
    stack = [(target_node, 0)]  # Each element is (node_id, current depth)
    slice_with_labels = {}

    while stack:
        node, depth = stack.pop()
        if node not in visited and depth <= max_hops:
            visited.add(node)

            node_obj = graph.get_node(node)
            label = node_obj.attr.get("label", node)
            slice_with_labels[node] = label

            if depth < max_hops:
                predecessors = graph.predecessors(node)
                for pred in predecessors:
                    stack.append((pred, depth + 1))
    return slice_with_labels

# Load the PDG from the given DOT file
dot_file = args.dotfile
graph = load_pdg(dot_file)

# Get the target node
target_node = args.number  # Node ID to start slicing from

# Perform backward slicing and collect nodes with their labels
slice_nodes_with_labels = backward_slice_with_labels(graph, target_node, max_hops=7)

# Output the result to a label file
labelfilename = "/Users/scduan/bin/joern/joern-cli/result/" + args.dotfile + "/" + str(args.number) + "lable.txt"
with open(labelfilename, "a") as file:
    for label in slice_nodes_with_labels.items():
        file.write(f"{label}\n")


