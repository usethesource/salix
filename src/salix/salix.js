

/*
 *
 * Here's another problem of ordering:
 * 
Processing: sub(clock(tick(1483357114)))
Processing: sub(clock(tick(1483357115)))
Processing: sub(clock(tick(1483357116)))
Processing: sub(clock(tick(1483357117)))
Processing: sub(clock(tick(1483357118)))
Processing: sub(clock(toggle()))
Processing: sub(clock(tick(1483357119)))

 */


function Salix(aRootId) {
	var rootId = aRootId || 'root';
	
	var async_queue = [];
	var event_queue = [];
	var other_queue = [];

	var natives = {};
	var subscriptions = {};
	var builders = {};

	function start() {
		buildInitialView();

		window.requestAnimationFrame(render);
	}

	function render(timestamp) {
		window.requestAnimationFrame(render);

		if (!pendingWork()) {
			return; 
		}
		
		if (waitingForResponse()) { 
			flushUIEvents();
			return;
		}
		
		processMessage(nextMessage());
	}

	function pendingWork() {
		return async_queue.length > 0 || event_queue.length > 0 || other_queue.length > 0;
	}

	function nextMessage() {
		return async_queue.length > 0 ? async_queue.shift() 
				  : (event_queue.length > 0 ? event_queue.shift() 
						  : other_queue.shift());
	}

	function flushUIEvents() {
		console.log("Flushing pending events: " + JSON.stringify(event_queue));
		event_queue = [];
	}

	function buildInitialView() {
		send('/init', {}, function (work) {
			doCommands(work[2]);
			subscribe(work[1]); 
			replace(root(), build(work[0]));
		});
	}

	function processMessage(msg) {
		send('/msg', msg, function (work) {
			doCommands(work[2]);
			subscribe(work[1]);
			patch(root(), work[0], dec2handler);
		});
	}

	var waiting = false;

	function waitingForResponse() {
		return waiting;
	}

	function send(url, message, handle) {
		waiting = true;
		$.get(url, message, handle, 'json').always(function () {
			waiting = false;
		});
	}

	function root() {
		return document.getElementById('root');
	}

	function replace(dom, newDom) {
		dom.parentNode.replaceChild(newDom, dom);
	}

	function nodeType(node) {
		for (var type in node) { break; }
		return type;
	}

	function doCommands(cmds) {
		for (var i = 0; i < cmds.length; i++) {
			var cmd = cmds[i];
			
			switch (nodeType(cmd)) {
			
			case 'random':
				var random = Math.floor(Math.random() * (cmd.random.to - cmd.random.from + 1)) + cmd.random.from;
				schedule(other_queue, cmd.random.handle.handle, {type: 'integer', intVal: random});
				break;
			
			}
			
		}
	}

	function sub2handler(sub) {
		switch (nodeType(sub)) {
		
		case 'timeEvery':
			var timer = setInterval(function() {
				var data = {type: 'integer', intVal: (new Date().getTime() / 1000) | 0};
				schedule(other_queue, sub.timeEvery.handle.handle, data); 
			}, sub.timeEvery.interval);
			return function () {
				clearInterval(timer);
			};
			
		}
	}

	function subscribe(subs) {
		for (var i = 0; i < subs.length; i++) {
			var sub = subs[i];
			var type = nodeType(sub);
			var id = sub[type].handle.handle.id;
			if (subscriptions.hasOwnProperty(id)) {
				continue;
			}
			subscriptions[id] = sub2handler(sub);
		}

		unsubscribeStaleSubs(subs);
	}

	function unsubscribeStaleSubs(subs) {
		var toDelete = [];
		outer: for (var k in subscriptions) {
			if (subscriptions.hasOwnProperty(k)) {
				for (var i = 0; i < subs.length; i++) {
					var sub = subs[i];
					var id = sub[nodeType(sub)].handle.handle.id;
					if (('' + id) === k) {
						continue outer;
					}
				}
				toDelete.push(k);
			}
		}
		for (var i = 0; i < toDelete.length; i++) {
			subscriptions[toDelete[i]](); // shutdown
			delete subscriptions[toDelete[i]];
		}
	}

	function scheduleEvent(handle, data) {
		schedule(event_queue, handle, data);
	}

	function scheduleAsync(handle, data) {
		schedule(async_queue, handle, data);
	}

	function schedule(queue, handle, data) {
		var result = {id: handle.id};
		if (handle.maps) {
			result.maps = handle.maps.join(';'); 
		}
		for (var k in data) {
			if (data.hasOwnProperty(k)) {
				result[k] = data[k];
			}
		}
		queue.push(result);
	}

	// this needs adaptation if new kinds of data are required. 
	function dec2handler(decoder) {
		switch (nodeType(decoder)) {
		
		case 'succeed':
			return function (event) {	
				// TODO: change 'nothing' to 'ok'
				schedule(event_queue, decoder.succeed.handle.handle, {type: 'nothing'});
			};
			
		case 'targetValue':
			return function (event) {
				schedule(event_queue, decoder.targetValue.handle.handle, 
						{type: 'string', strVal: event.target.value});
			};
			
		case 'targetChecked':
			return function (event) {	
				schedule(event_queue, decoder.targetChecked.handle.handle, 
						{type: 'boolean', boolVal: event.target.checked});
			};
			
		}
	}

	function patchThis(dom, edits) {
		edits = edits || [];

		for (var i = 0; i < edits.length; i++) {
			var edit = edits[i];
			var type = nodeType(edit);

			switch (type) {
			
			case 'replace':
				return build(edit[type].html);

			case 'setText': // can't happen if dom is native
				dom.nodeValue = edit[type].contents;
				break;			
				
			case 'removeNode': // can't happen if dom is native
				dom.removeChild(dom.lastChild);
				break;
				
			case 'appendNode': // can't happen if dom is native
				var kid = build(edit[type].html);
				if (typeof kid === 'function') {
					kid(dom);
				}
				else {
					dom.appendChild(kid);
				}
				break;
				
			case 'setAttr': // can't happen if dom is native
				dom.setAttribute(edit[type].name, edit[type].val);
				break;
				
			case 'setProp': // goes to native if dom was native
				dom[edit[type].name] = edit[type].val;
				break;
				
			case 'setEvent': // goes to native if dom was native (TODO)
				var key = edit[type].name;
				var handler = dec2handler(edit[type].handler);
				dom.addEventListener(key, withCleanListeners(dom, key, handler));
				break
			
			case 'removeAttr': // can't happen if dom is native
				dom.removeAttribute(edit[type].name);
				break;
				
			case 'removeProp': // goes to native if dom was native
				delete dom[edit[type].name];
				break;
				
			case 'removeEvent': // goes to native if dom was native
				// todo: refactor
				var handler = dom.salix_handlers[edit[type].name];
				dom.removeEventListener(edit[type].name, handler);
				break;
				
			default: 
				throw 'unsupported edit: ' + JSON.stringify(edit);
				
			}
		}
	}
	
	function patch(dom, tree) {
		var newDom = dom.salix_native 
		  	? dom.salix_native.patch(tree.patch.edits)
		  	: patchThis(dom, tree.patch.edits);
		
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
		var allHandlers = dom.salix_handlers || {};
		if (allHandlers.hasOwnProperty(key)) {
			dom.removeEventListener(key, allHandlers[key]);
		}
		allHandlers[key] = handler;
		dom.salix_handlers = allHandlers;
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
	    var vevents = vdom.element.events || {};
	    
	    
	    var elt = vprops.namespace != undefined
	            ? document.createElementNS(vprops.namespace, vdom.element.tagName)
	            : document.createElement(vdom.element.tagName);
	    
	    updateAttrsPropsAndEvents(elt, vattrs, vprops, vevents);       
        
	    for (var i = 0; i < vdom.element.kids.length; i++) {
	    	var kid = build(vdom.element.kids[i]);
	    	if (typeof kid === 'function') {
	    		kid(elt);
	    	}
	    	else {
	    		elt.appendChild(kid);
	    	}
	    }
	    
	    return elt;    
	}
	
	function updateAttrsPropsAndEvents(elt, vattrs, vprops, vevents) {
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
	    
	    for (var k in vevents) {
	    	if (vevents.hasOwnProperty(k)) {
	    		elt.addEventListener(k, withCleanListeners(elt, k, dec2handler(vevents[k])));
	    	}
	    }
	}

	function registerNative(kind, builder) {
		builders[kind] = builder;
	}
	
	function makeNative(native) {
		return function (parent) {
			return builders[native.kind](parent, native.props, native.events, native.extra);
		}
	}

	return {start: start, 
			registerNative: registerNative,
			build: build,
			nodeType: nodeType,
			scheduleEvent: scheduleEvent,
			scheduleAsync: scheduleAsync};
}



