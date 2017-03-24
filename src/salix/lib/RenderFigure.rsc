module salix::lib::RenderFigure

import salix::Node;
import salix::Core;
import salix::lib::Figure;
import salix::lib::LayoutFigure;
import IO;
import Node;


data FProp
  = cx(num x)
  | cy(num y)
  | rx(num x)
  | ry(num y)
  | r(num r)
  | text(str txt)
  | scaleX(Rescale rs)
  | scaleY(Rescale rs)
  | points(Points points)
  | yReverse(bool b)
  | xReverse(bool b)
  | connected(bool b)
  | closed(bool b)
  | curved(bool b)
  | padding(tuple[int left, int top, int right, int bottom] padding)
  | width(int w)
  | height(int h)
  | rotate(Rotate rotate)
  | position(Position pos)
  | align(Alignment align)
  | cellAlign(Alignment align)
  | bigger(num x)
  | shrink(num s)
  | hshrink(num hshrink)
  | vshrink(num vshrink)
  | grow(num grow)
  | hgrow(num hgrow)
  | vgrow(num vgrow)
  | resizable(bool b)
  | gap(tuple[int hgap, int vgap] hvgap) // todo: fix superfluous tuples here.
  | hgap(int hgap)
  | vgap(int vgap)
  | lineWidth(int w)
  | lineColor(str color)
  | lineDashing(list[int] ds)
  | lineOpacity(num opacity)
  | fillColor(str color)
  | fillOpacity(num opacity)
  | fillRule(str rule)
  | clipPath(list[str] path)
  | rounded(tuple[int r1, int r2] rounded)
  ; 
  
alias FigF = void(list[value]);
alias HtmlF = void(int, int, void()); 

alias Fig = tuple[

  // Primitives
  FigF box,
  FigF ellipse,
  FigF circle,
  FigF ngon,
  FigF polygon,
  
  
  //FigF shape, // needs nesting with start/mid/end marker
  //FigF path, // needs nesting with start/mid/end marker
  
  FigF hcat,
  FigF vcat,
  FigF overlay,
  FigF grid,
  
  // embedding salix
  HtmlF html
];

data Figure
 = dummy(list[Figure] figs = [])
 // TODO: extend eval to interpret this figure
 | html(int width, int height, Node n)
 ;

Figure setProps(Figure f, list[value] vals) {
  map[str,value] update(map[str,value] kws, FProp fp)
    = kws + (getName(fp): getChildren(fp)[0]); // assumes all props have 1 arg
    
  return ( f | setKeywordParameters(it, update(getKeywordParameters(it), fp)) | FProp fp <- vals );
}

void figure(num w, num h, void(Fig) block) {
  list[Figure] stack = [dummy()];
  
  Figure pop() {
    Figure p = stack[-1];
    stack = stack[0..-1];
    return p;
  }
  
  void push(Figure f) {
    stack += [f];
  }
  
  void add(Figure f) {
    Figure t = pop();
    
    // todo: should all be figs
    if (t has figs) {
      t.figs += [f];
    }
    else if (t has fig) {
      t.fig = f;
    } // else ignore...
    push(t);
  }
  
  void makeFig(Figure base, list[value] vals) {
    push(base);
    if (vals != [], void() block := vals[-1]) {
      block();
    }
    add(setProps(pop(), vals));
  }
  
  void _box(value vals...) = makeFig(Figure::box(), vals);
  void _ellipse(value vals...) = makeFig(Figure::ellipse(), vals);
  void _circle(value vals...) = makeFig(Figure::circle(), vals);
  void _ngon(value vals...) = makeFig(Figure::ngon(), vals);
  void _polygon(value vals...) = makeFig(Figure::polygon(), vals);
  
  // vs should be keyword arg
  //void shape(list[Vertex] vs, value vals...) = makeFig(Figure::shape(vs), vals);
  
  // these things should also have only keyword args for consistency
  // void path(...)
  // void textpath...
  
  // and start/end/mid marker should be just figs
  
  void _hcat(value vals...) = makeFig(Figure::hcat(), vals);
  void _vcat(value vals...) = makeFig(Figure::vcat(), vals);
  void _overlay(value vals...) = makeFig(Figure::overlay(), vals);
  void _grid(value vals...) = makeFig(Figure::grid(), vals);
  
  // NB: block should draw 1 node
  void _html(int w, int h, void() block) = add(Figure::html(w, h, render(block))); 
  
  block(<_box, _ellipse, _circle, _ngon, _polygon, _hcat, _vcat, _overlay, _grid, _html>);
  
  iprintln(stack[-1].figs[0]);
  salix::lib::LayoutFigure::fig(stack[-1].figs[0], width=w, height=h);
  //addNode(render(eval(stack[-1].figs[0])));
}
