

/*
 * TODO
 * - figure out how to avoid out of order processing...
 */

var __queue = [];

var __natives = {};

var __builders = {
	codeMirror: function(parent, attrs, props, events) {
		var cm = CodeMirror(parent, {
			lineNumbers: true,
			matchBrackets: true,
			tabMode: 'shift',
			autofocus: true,
			value: "function myScript(){return 100;}\n",
			mode:  "javascript"
		});
		cm.refresh();
		console.log(cm);
		cm.on('cursorActivity', function (editor) {
			var position = editor.getCursor();
			var line = position.line;
			var token = editor.getTokenAt(position);
			schedule(events.cursorActivity,  {line: line, start: token.start, 
				end: token.end, string: token.string, tokenType: token.type});
		});
	}
};

function makeNative(native) {
	if (!__natives.hasOwnProperty(native.key)) {
		__natives[native.key] = function(parent) {
			return __builders[native.kind](parent, native.attrs, native.props, native.events);
		};
	}
	return __natives[native.key];
}

function render(timestamp) {
	window.requestAnimationFrame(render);
	if (__queue.length == 0) {
		return;
	}
	var payload = __queue.shift();
	$.get('/msg', payload, function (p, stats, jqXHR) {
		// TODO: receive commands here too which will have to be interpreted
		patch(root(), p, dec2handler);
	}, 'json');
}

function root() {
	return document.getElementById('root');
}

function start() {
	$.get('/init', {}, function (tree, stats, jqXHR) {
		replace(root(), build(tree));
	}, 'json');
	window.requestAnimationFrame(render);
}

function replace(dom, newDom) {
	dom.parentNode.replaceChild(newDom, dom);
}

function schedule(dec, data) {
	for (var type in dec) { break; }
	var ret = dec[type].handle.handle;
	ret.type = type;
	if (data) {
		for (var k in data) {
			if (data.hasOwnProperty(k)) {
				ret[k] = data[k];
			}
		}
	}
	__queue.push(ret);
}

// this needs adaptation if new kinds of data are required. 
function dec2handler(decoder) {
	for (var cons in decoder) {

		switch (cons) {
		
		case 'succeed':
			return function (event) {	
				schedule(decoder);
			};
			
		case 'targetValue':
			return function (event) {
				schedule(decoder, {data: event.target.value});
			};
			
		case 'targetChecked':
			return function (event) {	
				schedule(decoder, {data: event.target.checked});
			};
			
		case 'oneKeyCode':
			return function (event) {	
				if (event.keyCode == decoder.oneKeyCode.keyCode) {
					schedule(decoder, {data: event.keyCode});
				}		
			};
		}
		break;
	}
}

function patchThis(dom, edits) {
	edits = edits || [];
	for (var i = 0; i < edits.length; i++) {
		var edit = edits[i];
		for (var type in edit) {
			
			switch (type) {
			
			case 'replace':
				return build(edit[type].html);
	
			case 'setText':
				dom.nodeValue = edit[type].contents;
				break;			
				
			case 'removeNode':
				dom.removeChild(dom.lastChild);
				break;
				
			case 'appendNode':
				var kid = build(edit[type].html);
				if (typeof kid === 'function') {
					kid(dom);
				}
				else {
					dom.appendChild(kid);
				}
				break;
				
			case 'setAttr':
				dom.setAttribute(edit[type].name, edit[type].val);
				break;
				
			case 'setProp':
				dom[edit[type].name] = edit[type].val;
				break;
				
			case 'setEvent':
				var key = edit[type].name;
				var handler = dec2handler(edit[type].decoder);
				dom.addEventListener(key, withCleanListeners(dom, key, handler));
				break
			
			case 'removeAttr':
				dom.removeAttribute(edit[type].name);
				break;
				
			case 'removeProp':
				delete dom[edit[type].name]; //???
				break;
				
			case 'removeEvent':
				// todo: refactor
				var handler = dom.myHandlers[edit[type].name];
				dom.removeEventListener(edit[type].name, handler);
				break;
				
			default: 
				throw 'unsupported edit: ' + JSON.stringify(edit);
				
			}
			break;
		}
	}
}

function patch(dom, tree) {
	var newDom = patchThis(dom, tree.patch.edits);
	
	if (newDom) {
		replace(dom, newDom);
		return;
	}
	
	var patches = tree.patch.patches || [];
	for (var i = 0; i < patches.length; i++) {
		var p = patches[i];
		patch(dom.childNodes[p.patch.pos], p);
	}
	
}

function withCleanListeners(dom, key, handler) {
	var allHandlers = dom.myHandlers || {};
	if (allHandlers.hasOwnProperty(key)) {
		dom.removeEventListener(key, allHandlers[key]);
	}
	allHandlers[key] = handler;
	dom.myHandlers = allHandlers;
	return handler;
}

function build(vdom) {
    if (vdom === undefined) {
        return document.createTextNode('');
    }
    
    if (vdom.txt !== undefined) {
        return document.createTextNode(vdom.txt.contents);
    }
    
    if (vdom.native !== undefined) {
    	return makeNative(vdom.native);
    }
    
    var elt = document.createElement(vdom.element.tagName);
    var vattrs = vdom.element.attrs || {};
    
    for (var k in vattrs) {
        if (vattrs.hasOwnProperty(k)) {
            elt.setAttribute(k, vattrs[k]);
        }
    }
    
    var vprops = vdom.element.props || {};
    for (var k in vprops) {
    	if (vprops.hasOwnProperty(k)) {
    		elt[k] = vprops[k];
    	}
    }
    
    
    var vevents = vdom.element.events || {};
    for (var k in vevents) {
    	if (vevents.hasOwnProperty(k)) {
    		elt.addEventListener(k, withCleanListeners(elt, k, dec2handler(vevents[k])));
    	}
    }
    
    for (var i = 0; i < vdom.element.kids.length; i++) {
    	var kid = build(vdom.element.kids[i]);
    	if (typeof kid === 'function') {
    		// natives append themselves
    		kid(elt);
    	}
    	else {
    		elt.appendChild(kid);
    	}
    }
    
    return elt;    
}
