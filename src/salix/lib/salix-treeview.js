/**
 * Copyright (c) Tijs van der Storm <Centrum Wiskunde & Informatica>.
 * All rights reserved.
 *
 * This file is licensed under the BSD 2-Clause License, which accompanies this project
 * and is available under https://opensource.org/licenses/BSD-2-Clause.
 * 
 * Contributors:
 *  - Tijs van der Storm - storm@cwi.nl - CWI
 */

function registerTreeView(salix) {
	
	function fromTreeNode(treeNode) {
		var tree = [];
		for (var i = 0; i < treeNode.length; i++) {
			var cur = treeNode[i];
			var node = cur.tnode;
			if (cur.tnode.nodes) {
				node.nodes = fromTreeNode(cur.tnode.nodes);
			}
			if (cur.tnode.state) {
				node.state = cur.tnode.state.tstate;
			}
			if (!cur.tnode.id) {
				node.data = {id: node.text};
			}
			tree.push(node);
		}
		return tree;
	}
	
	function toTreeNode(node) {
		var tn = {tnode: {}};
		for (var k in node) {
			if (node.hasOwnProperty(k)) {
				if (k === 'nodes') {
					tn.tnode.nodes = [];
					for (var i = 0; i < node.nodes.length; i++) {
						tn.tnode.nodes.push(toTreeNode(node.nodes[i]));
					}
				}
				else if (k === 'state') {
					tn.tnode.state = {tstate: node.state};
				}
				else if (k === 'data') {
					if (node[k].id) {
						tn.tnode.id = node[k].id;
					}
					tn.tnode[k] = node[k];
				}
				else if (k === 'text' || k === 'icon'
						|| k === 'selectedIcon' || k === 'color'
						|| k === 'backColor' || k === 'href'
						|| k === 'tags'
						|| k === 'selectable') {
					tn.tnode[k] = node[k];
				}
			}
		}
		return tn;
	}
	
	function toTreeNodes(nodes) {
		var result = [];
		for (var i = 0; i < nodes.length; i++) {
			result.push(toTreeNode(nodes[i]));
		}
		return result;
	}
	
	
	salix.Decoders.node = function (args) {
		return function (event, node) {
			return {type: 'nodeId', node: node.data.id};
		}
	};
	
	salix.Decoders.results = function (args) {
		return function (event, nodes) {
			var nodeIds = [];
			for (var i = 0; i < nodes.length; i++) {
				nodeIds.push(nodes[i].data.id);
			}
			return  {type: 'listOfNodeId', results: JSON.stringify(toTreeNodes(nodes))};
		};
	};
	
	function treeView(attach, id, attrs, props, events, extra) {
		var div = document.createElement('div');
		div.id = id;
		attach(div);
		
		// for remove event.
		var myHandlers = {};
		
		var treeNode = extra.data;
		var options = attrs;
		options.data = fromTreeNode(treeNode);
		var dom = '#' + id;
		$(dom).treeview(options);
		
		for (var key in events) {
			if (events.hasOwnProperty(key)) {
				var handler = salix.getNativeHandler(events[key]);
				myHandlers[key] = handler;
				$(dom).on(key, handler);
			}
		}

		
		function patch(edits, attach) {
			edits = edits || [];

			for (var i = 0; i < edits.length; i++) {
				var edit = edits[i];
				var type = salix.nodeType(edit);

				switch (type) {
				
				case 'setExtra':
					options.data = fromTreeNode(edit[type].value);
					$(dom).treeview(options);
					break;
					
				
				case 'setAttribute':
					options[edit[type].name] = edit[type].value;
					$(dom).treeview(options);
					break;
					
				case 'removeAttribute':
					delete options[edit[type].name];
					$(dom).treeview(options);
					break;
				
				case 'replace':
					salix.build(edit[type].html, attach);
					break;

				case 'setEvent': 
					var key = edit[type].name;
					var handler = salix.getNativeHandler(edit[type].handler);
					myHandlers[key] = handler;
					$(dom).on(key, handler);
					break
				
				case 'removeEvent':
					var key = edit[type].name
					$(dom).off(key, myHandlers[key]);
					delete myHandlers[key];
					break;
					
				default: 
					throw 'unsupported edit: ' + JSON.stringify(edit);
					
				}
			}
		}
		
		div.salix_native = {patch: patch};
	}
	
	function doCommand(cmd) {
		// TODO
	}
	
	salix.registerNative('treeView', treeView);
};