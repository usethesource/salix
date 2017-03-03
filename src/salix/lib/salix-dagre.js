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
	
	function myDagre(attach, id, attrs, props, events, extra) {

		var g = new dagreD3.graphlib.Graph().setGraph({});

		var nodes = extra.nodes;
		var edges = extra.edges;
		
		for (var i = 0; i < nodes.length; i++) {
			var theNode = nodes[i].gnode;
			var nodeAttrs = {};
			nodeAttrs.label = 
				function() {
					var myDomNode = undefined;
					salix.build(theNode.label, function(kid) {
						myDomNode = kid;
					});
					return myDomNode;
				};
			
			for (var k in attrs) {
				if (attrs.hasOwnProperty(k)) {
					nodeAttrs[k] = attrs[k];
				}
			}
			g.setNode(theNode.id, nodeAttrs);
		}
		
		for (var i = 0; i < edges.length; i++) {
			var theEdge = edges[i].gedge;
			g.setEdge(theEdge.from, theEdge.to, theEdge.attrs || {label: 'bla'});
		}
		
		var _svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
		_svg.id = id;
		attach(_svg);
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
			var patching = charts[id];
			
			for (var i = 0; i < edits.length; i++) {
				var edit = edits[i];
				var type = salix.nodeType(edit);

				switch (type) {
				
				case 'setExtra':
					break;
				
				case 'replace':
					return salix.build(edit[type].html, attach);

				}
			}
		}
		
        
		svgGroup.salix_native = {patch: patch};
		return svgGroup;
	}
	
	salix.registerNative('dagre', myDagre);
};