module salix::lib::Dagre

import salix::Core;
import salix::HTML;
import salix::Node;

import IO;

alias N = void(str, list[value]);
alias E = void(str, str, list[value]);

alias G = void(N, E);

/*

void view() {
  dagre("myGraph", (N n, E e) {
     n("a", () {
       button(onClick(bla()), "Hello");
     });
     
     n("b", ...)
     
     e("a", "b");
     e("b", "c");
  });

}


*/

// SVG *attributes* from salix::SVG can be given to the dagre function and will be put on the SVG container
// The following props given to the dagre function will be interpreted as props for Dagre layout algo.
// This means that for now, you can't set props on the SVG dom object, only attributes.
// Source: https://github.com/cpettitt/dagre/wiki#configuring-the-layout

// Graph attributes/props
Attr rankdir(str rd) = prop("rankdir", rd);  // TB  Direction for rank nodes. Can be TB, BT, LR, or RL, where T = top, B = bottom, L = left, and R = right.
Attr align(str rd) = prop("align", rd); // TB  Alignment for rank nodes. Can be UL, UR, DL, or DR, where U = up, D = down, L = left, and R = right.
Attr nodesep(int ns) = prop("nodesep", "<ns>"); // 50  Number of pixels that separate nodes horizontally in the layout.
Attr edgesep(int es) = prop("edgesep", "<es>"); //10  Number of pixels that separate edges horizontally in the layout.
Attr ranksep(int rs) = prop("ranksep", "<rs>"); //50  Number of pixels between each rank in the layout.
Attr marginx(int mx) = prop("marginx", "<mx>"); // 0 Number of pixels to use as a margin around the left and right of the graph.
Attr marginy(int my) = prop("marginy", "<my>"); // 0 Number of pixels to use as a margin around the top and bottom of the graph.
Attr acyclicer() = prop("acyclicer", "greedy"); //undefined If set to greedy, uses a greedy heuristic for finding a feedback arc set for a graph. A feedback arc set is a set of edges that can be removed to make a graph acyclic.
Attr ranker(str name) = prop("ranker", name); // network-simplex  Type of algorithm to assigns a rank to each node in the input graph. Possible values: network-simplex, tight-tree or longest-path  network-


// Node attributes/props



// Node rendering attributes (provide to N function)
// rect, circle, ellipse, diamond
Attr shape(str name) = attr("shape", name);
Attr labelStyle(tuple[str,str] styles...) = attr("labelStyle", intercalate("; ", ["<k>: <v>" | <k, v> <- styles ]));
Attr labelStyle(map[str,str] styles) = attr("labelStyle", intercalate("; ", ["<k>: <styles[k]>" | k <- styles ]));
Attr fill(str color) = attr("fill", color);

//Attr nodeWidth(int w) = attr("
//node  width 0 The width of the node in pixels.
//node  height  0 The height of the node in pixels. 

//style() is also supported

// Edge attributes (provide to an E function)
Attr arrowheadStyle(tuple[str,str] styles...) = attr("arrowHeadStyle", intercalate("; ", ["<k>: <v>" | <k, v> <- styles ]));
Attr arrowheadStyle(map[str,str] styles) = attr("arrowHeadStyle", intercalate("; ", ["<k>: <styles[k]>" | k <- styles ])); 
Attr arrowheadClass(str class) = attr("arrowheadClass", class);

// https://github.com/d3/d3-3.x-api-reference/blob/master/SVG-Shapes.md#line_interpolate
Attr lineInterpolate(str interp) = attr("lineInterpolate", interp);




data GNode = gnode(str id, map[str,str] attrs = (), Node label = txt(""));
data GEdge = gedge(str from, str to, map[str, str] attrs = ());

void dagre(str gid, value vals...) {
  list[GNode] nodes = [];
  list[GEdge] edges = [];
  
  void n(str id, value vals...) {
    GNode myNode = gnode(id);
    if (vals != []) {
      if (void() labelFunc := vals[-1]) {
        Node label = render(labelFunc);
        myNode.label = label;
      }
      else if (str label := vals[-1]) {
        myNode.label = txt(label);
      }
      myNode.attrs = attrsOf([ a | Attr a <- vals ]);
      nodes += [myNode];
    }
  }
  
  void e(str from, str to, value vals...) {
    GEdge myEdge = gedge(from, to);
    if (vals != []) {
      myEdge.attrs = attrsOf([ a | Attr a <- vals ]);
    }
    edges += [myEdge];
  }
  
  if (vals != []) {
    if (G g := vals[-1]) {
      g(n, e);
    }
  }

  list[Attr] myAttrs = [ a | Attr a <- vals ];  
  
  build([], Node(list[Node] _, list[Attr] _) {
       return native("dagre", gid, attrsOf(myAttrs), propsOf(myAttrs), (),
         extra = (
           "nodes": nodes,
           "edges": edges
         ));
    });
  
}

