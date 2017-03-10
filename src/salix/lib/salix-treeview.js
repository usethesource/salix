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
	
	function fromTreeNode(treeNodes) {
		var tree = [];
		for (var i = 0; i < treeNodes.length; i++) {
			var cur = treeNodes[i];
			var node = {text: cur.tree.text};
			node.data = {id: cur.tree.text};
			if (cur.tree.nodes) {
				node.nodes = fromTreeNode(cur.tree.nodes);
			}
			if (cur.tree.attrs) {
				var attrs = cur.tree.attrs;
				if (attrs.id) {
					node.data = {id: attrs.id};
				}
				for (var k in attrs) {
					if (attrs.hasOwnProperty(k)) {
						if (k === 'checked' || k === 'disabled' ||
								k === 'expanded' || k === 'selected') {
							if (!node.state) {
								node.state = {};
							}
							node.state[k] = attrs[k];
						}
						else {
							node[k] = attrs[k];
						}
					}
				}
			}
			tree.push(node);
		}
		return tree;
	}
	
	
	salix.Decoders.node = function (args) {
		return function (event, node) {
			return {type: 'nodeId', node: node.data.id};
		}
	};
	
//	salix.Decoders.results = function (args) {
//		return function (event, nodes) {
//			var nodeIds = [];
//			for (var i = 0; i < nodes.length; i++) {
//				nodeIds.push(nodes[i].data.id);
//			}
//			return  {type: 'listOfNodeId', results: JSON.stringify(toTreeNodes(nodes))};
//		};
//	};
	
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