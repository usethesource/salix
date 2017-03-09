module salix::lib::TreeView

//https://github.com/jonmiles/bootstrap-treeview

import salix::Node;
import salix::Core;

import lang::json::IO;

data TreeState
  = tstate(bool checked = false, bool disabled = false, bool expanded = false, bool selected = false);

data TreeNode
  = tnode(str text, list[TreeNode] nodes = [], 
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

Attr onNodeChecked(Msg(TreeNode) tn2msg) = event("nodeChecked", handler("node", encode(tn2msg)));
Attr onNodeCollapsed(Msg(TreeNode) tn2msg) = event("nodeCollapsed", handler("node", encode(tn2msg)));
Attr onNodeDisabled(Msg(TreeNode) tn2msg) = event("nodeDisabled", handler("node", encode(tn2msg)));
Attr onNodeEnabled(Msg(TreeNode) tn2msg) = event("nodeEnabled", handler("node", encode(tn2msg)));
Attr onNodeExpanded(Msg(TreeNode) tn2msg) = event("nodeExpanded", handler("node", encode(tn2msg)));
Attr onNodeSelected(Msg(TreeNode) tn2msg) = event("nodeSelected", handler("node", encode(tn2msg)));
Attr onNodeUnchecked(Msg(TreeNode) tn2msg) = event("nodeUnchecked", handler("node", encode(tn2msg)));
Attr onNodeUnselected(Msg(TreeNode) tn2msg) = event("nodeUnselected", handler("node", encode(tn2msg)));
Attr onSearchComplete(Msg(list[TreeNode]) tns2msg) = event("searchComplete", handler("results", encode(tns2msg)));
Attr onSearchCleared(Msg(list[TreeNode]) tns2msg) = event("searchCleared", handler("results", encode(tns2msg)));

Msg parseMsg("treeNode", Handle h, map[str, str] p)
  = applyMaps(h, decode(h, #(Msg(TreeNode)))(fromJSON(#TreeNode, params["node"])));

Msg parseMsg("listOfTreeNode", Handle h, map[str, str] p)
  = applyMaps(h, decode(h, #(Msg(list[TreeNode])))(fromJSON(#list[TreeNode], params["results"])));

void treeView(str id, list[TreeNode] tree, value vals...)
  = build(vals, Node(list[Node] _, list[Attr] attrs) {
       return native("treeView", id, attrsOf(attrs), (), eventsOf(attrs), extra = ("data": tree));
    });