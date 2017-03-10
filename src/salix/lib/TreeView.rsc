module salix::lib::TreeView

//https://github.com/jonmiles/bootstrap-treeview

import salix::Node;
import salix::Core;

import lang::json::IO;
import IO;

data TreeState
  = tstate(bool checked = false, bool disabled = false, bool expanded = false, bool selected = false);

// If id is absent, use text as identifier.

data TreeNode
  = tnode(str text, str id = "", list[TreeNode] nodes = [], 
          str icon = "", str selectedIcon = "", str color = "", str backColor = "", str href = "", bool selectable = true, 
          TreeState state = tstate(), list[str] tags = [], map[str, value] \data = ());
          

// Attrs are interpreted as options to the treeview.
Attr backColor(str color) = attr("backColor", color);
Attr borderColor(str color) = attr("borderColor", color);
Attr checkedIcon(str glyph) = attr("checkedIcon", glyph);
Attr collapseIcon(str glyph) = attr("collapseIcon", glyph);
Attr color(str color) = attr("color", color);
Attr emptyIcon(str glyph) = attr("emptyIcon", glyph);
Attr enableLinks() = attr("enableLinks", "true");
Attr expandIcon(str glyph) = attr("expandIcon", glyph);
Attr highlightSearchResults(bool b) = attr("highlightSearchResults", "<b>");
Attr highlightSelected(bool b) = attr("highlightSelected", "<b>");
Attr levels(int n) = attr("levels", "<n>");
Attr multiSelect() = attr("multiSelect", "true");
Attr nodeIcon(str glyph) = attr("nodeIcon", glyph);
Attr onhoverColor(str color) = attr("onhoverColor", color);
Attr selectedIcon(str glyph) = attr("selectedIcon", glyph);
Attr searchResultBackColor(str color) = attr("searchResultBackColor", color);
Attr searchResultColor(str color) = attr("searchResultColor", color);
Attr selectedBackColor(str color) = attr("selectedBackColor", color);
Attr selectedColor(str color) = attr("selectedColor", color);
Attr showBorder(bool b) = attr("showBorder", "<b>");
Attr showCheckbox() = attr("showCheckbox", "true");
Attr showIcon(bool b) = attr("showIcon", "<b>");
Attr showTags() = attr("showTags", "true");
Attr uncheckedIcon(str glyph) = attr("uncheckedIcon", glyph);

Attr onNodeChecked(Msg(str) tn2msg) = event("nodeChecked", handler("node", encode(tn2msg)));
Attr onNodeCollapsed(Msg(str) tn2msg) = event("nodeCollapsed", handler("node", encode(tn2msg)));
Attr onNodeDisabled(Msg(str) tn2msg) = event("nodeDisabled", handler("node", encode(tn2msg)));
Attr onNodeEnabled(Msg(str) tn2msg) = event("nodeEnabled", handler("node", encode(tn2msg)));
Attr onNodeExpanded(Msg(str) tn2msg) = event("nodeExpanded", handler("node", encode(tn2msg)));
Attr onNodeSelected(Msg(str) tn2msg) = event("nodeSelected", handler("node", encode(tn2msg)));
Attr onNodeUnchecked(Msg(str) tn2msg) = event("nodeUnchecked", handler("node", encode(tn2msg)));
Attr onNodeUnselected(Msg(str) tn2msg) = event("nodeUnselected", handler("node", encode(tn2msg)));
Attr onSearchComplete(Msg(list[str]) tns2msg) = event("searchComplete", handler("results", encode(tns2msg)));
Attr onSearchCleared(Msg(list[str]) tns2msg) = event("searchCleared", handler("results", encode(tns2msg)));


Msg parseMsg("nodeId", Handle h, map[str, str] p)
  = applyMaps(h, decode(h, #(Msg(str)))(p["node"]));

// TODO: fix this
Msg parseMsg("listOfNodeId", Handle h, map[str, str] p)
  = applyMaps(h, decode(h, #(Msg(list[str])))(p["results"]));

alias T = void(str id, list[value] vals);
alias TV = void(T);

//void treeView(str id, value vals...) {
//  list[list[TreeNode]] n = [[]];
//
//  void t(str id, value vals...) {
//     if (void() block := vals[-1]) {
//       n += [];
//       block();
//       n = n[0..-2] + [n[-2] + n[-1][0]]; 
//     }
//  }
//  
//  if (vals != []) {
//    if (TV tv := vals[-1]) {
//      tv(t);
//    }
//  }
//  
//  build(vals, Node(list[Node] _, list[Attr] attrs) {
//     return native("treeView", "treeView", attrsOf(attrs), (), eventsOf(attrs), extra = ("data": n[0]));
//  });
//}

void treeView(str id, list[TreeNode] tree, value vals...)
  = build(vals, Node(list[Node] _, list[Attr] attrs) {
       return native("treeView", id, attrsOf(attrs), (), eventsOf(attrs), extra = ("data": tree));
    });