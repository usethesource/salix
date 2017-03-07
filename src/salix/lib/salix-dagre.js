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

function registerDagre(salix) {
	
	var graphs = {};
	
	function dagreGraph(nodes, edges) {
		var g = new dagreD3.graphlib.Graph().setGraph({});
		
		function labelBuilder(label) {
			return function() {
				var myDomNode = undefined;
				salix.build(label, function(kid) {
					myDomNode = kid;
				});
				return myDomNode;
			};
		}
		
		for (var i = 0; i < nodes.length; i++) {
			var theNode = nodes[i].gnode;
			var nodeAttrs = {};
			nodeAttrs.label = labelBuilder(theNode.label);
			
			for (var k in theNode.attrs) {
				if (theNode.attrs.hasOwnProperty(k)) {
					nodeAttrs[k] = theNode.attrs[k];
				}
			}
			g.setNode(theNode.id, nodeAttrs);
		}
		
		for (var i = 0; i < edges.length; i++) {
			var theEdge = edges[i].gedge;
			g.setEdge(theEdge.from, theEdge.to, theEdge.attrs || {});
		}
		
		return g;
	}
	
	function myDagre(attach, id, attrs, props, events, extra) {

		
		//NB: used down below in patch
		var nodes = extra.nodes;
		var edges = extra.edges;
		
		var g = dagreGraph(nodes, edges);
		
		var _svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
		_svg.id = id;
		attach(_svg);
		// todo: these attrs should come from this function.
		_svg.setAttribute('width', 960);
		_svg.setAttribute('height', 600);
		

		var svg = d3.select('#' + id),
	    	svgGroup = svg.append('g');
		
		var render = new dagreD3.render();
		render(svgGroup, g);
		
		var xCenterOffset = (svg.attr('width') - g.graph().width) / 2;
		svgGroup.attr('transform', 'translate(' + xCenterOffset + ', 20)');
		svg.attr('height', g.graph().height + 40);
		
		function patch(edits, attach) {
			edits = edits || [];
			// todo: we need to lookup the graph, no?
			//var patching = charts[id];
			
			var newNodes;
			var newEdges;
			
			for (var i = 0; i < edits.length; i++) {
				var edit = edits[i];
				var type = salix.nodeType(edit);

				switch (type) {
				
				case 'setExtra':
					if (edit.setExtra.name === 'nodes') {
						newNodes = edit.setExtra.value;
					}
					if (edit.setExtra.name === 'edges') {
						newEdges = edit.setExtra.value;
					}
					break;
				
				case 'replace':
					return salix.build(edit[type].html, attach);

				}
			}
			
			if (newNodes && newEdges) {
				var newG = dagreGraph(newNodes, newEdges);
				nodes = newNodes;
				edges = newEdges;
				render(svgGroup, newG);
			}
			else if (newNodes) {
				var newG = dagreGraph(newNodes, edges);
				nodes = newNodes;
				render(svgGroup, newG);
			}
			else if (newEdges) {
				var newG = dagreGraph(nodes, newEdges);
				edges = newEdges;
				render(svgGroup, newG);
			}
			
		}
		
        
		_svg.salix_native = {patch: patch};
		return _svg;
	}
	
	salix.registerNative('dagre', myDagre);
};