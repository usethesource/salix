

/*
 * TODO
 * - figure out how to avoid out of order processing...
 */

var __queue = [];

var __natives = {};

var __subscriptions = {};

var __builders = {
	// TODO: separate appending, from creating somehow.
	// so that when appendNode appends codeMirror it works.
	// futher: natives should receive arb data to config etc.
	// e.g. in codemirror we can give a mode

	codeMirror: function(parent, attrs, props, events) {
		var cm = CodeMirror(parent, {
			lineNumbers: true,
			matchBrackets: true,
			tabMode: 'shift',
			autofocus: true,
			//value: "function myScript(){return 100;}\n",
			mode:  "javascript"
		});
		cm.getDoc().setValue(props['value']);
		setTimeout(function() {
            cm.refresh();
        }, 100);

		cm.on('cursorActivity', function (editor) {
			var position = editor.getCursor();
			var line = position.line;
			var token = editor.getTokenAt(position);
			if (events.cursorActivity) {
				schedule(events.cursorActivity,  {line: line, start: token.start, 
					end: token.end, string: token.string, tokenType: token.type});
			}
		});
		cm.on('change', function (editor, change) {
			if (events.change) {
				schedule(events.change,  {
					fromLine: change.from.line, fromCol: change.from.ch,
					toLine: change.to.line, toCol: change.to.ch,
					text: change.text.join('\n'),
					removed: change.removed.join("\n")
				});
			}
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
	$.get('/msg', payload, function (work, stats, jqXHR) {
		// todo: fix order
		doCommands(work[2]);
		subscribe(work[1]);
		patch(root(), work[0], dec2handler);
	}, 'json');
}

function root() {
	return document.getElementById('root');
}

function start() {
	$.get('/init', {}, function (work, stats, jqXHR) {
		doCommands(work[2]);
		subscribe(work[1]); // subscriptions
		replace(root(), build(work[0]));
	}, 'json');
	window.requestAnimationFrame(render);
}

function replace(dom, newDom) {
	dom.parentNode.replaceChild(newDom, dom);
}

function doCommands(cmds) {
	for (var i = 0; i < cmds.length; i++) {
		var cmd = cmds[i];
		for (var type in cmd) { break; } // todo: make function
		switch (type) {
		case 'random':
			var random = Math.floor(Math.random() * (cmd.random.to - cmd.random.from + 1)) + cmd.random.from;
			schedule(cmd.random.handle.handle, {type: 'integer', intVal: random});
			break;
		}
	}
}

function subscribe(subs) {
	//{timeEvery: {interval: ms, handle: {handle: ...}}}
	for (var i = 0; i < subs.length; i++) {
		var sub = subs[i];
		for (var type in sub) { break; }
		var id = sub[type].handle.handle.id;
		if (__subscriptions.hasOwnProperty(id)) {
			continue;
		}
		switch (type) {
		case 'timeEvery':
			var timer = setInterval(function() {
				var data = {type: 'integer', intVal: (new Date().getTime() / 1000) | 0};
				schedule(sub.timeEvery.handle.handle, data); 
			}, sub.timeEvery.interval);
			__subscriptions[id] = function () {
				clearInterval(timer);
			}; 
			
		}
	}
	var toDelete = [];
	outer: for (var k in __subscriptions) {
		if (__subscriptions.hasOwnProperty(k)) {
			for (var i = 0; i < subs.length; i++) {
				var sub = subs[i];
				for (var type in sub) { break; }
				var id = sub[type].handle.handle.id;
				if (('' + id) === k) {
					continue outer;
				}
			}
			toDelete.push(k);
		}
	}
	for (var i = 0; i < toDelete.length; i++) {
		__subscriptions[toDelete[i]](); // shutdown
		delete __subscriptions[toDelete[i]];
	}
	
}

function schedule(handle, data) {
	var result = {id: handle.id};
	if (handle.maps) {
		result.maps = handle.maps.join(';'); 
	}
	for (var k in data) {
		if (data.hasOwnProperty(k)) {
			result[k] = data[k];
		}
	}
	__queue.push(result);
}

// this needs adaptation if new kinds of data are required. 
function dec2handler(decoder) {
	for (var cons in decoder) {

		switch (cons) {
		
		case 'succeed':
			return function (event) {	
				schedule(decoder.succeed.handle.handle, {type: 'nothing'});
			};
			
		case 'targetValue':
			return function (event) {
				schedule(decoder.targetValue.handle.handle, 
						{type: 'string', strVal: event.target.value});
			};
			
		case 'targetChecked':
			return function (event) {	
				schedule(decoder.targetChecked.handle.handle, 
						{type: 'boolean', boolVal: event.target.checked});
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
				var handler = dec2handler(edit[type].handler);
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

    var vattrs = vdom.element.attrs || {};
    var vprops = vdom.element.props || {};
    
    var elt = vprops.namespace != undefined
            ? document.createElementNS(vprops.namespace, vdom.element.tagName)
            : document.createElement(vdom.element.tagName);
    
    for (var k in vattrs) {
        if (vattrs.hasOwnProperty(k)) {
            elt.setAttribute(k, vattrs[k]);
        }
    }
    
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
