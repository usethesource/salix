

/*

TODO (?): ordering issue with subscriptions

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
	
	var event_queue = [];
	var command_queue = [];
	var subscription_queue = [];
	var other_queue = [];

	// 'native 'dom elements
	var builders = {};

	var subscriptions = {};
	
	function start() {
		send('/init', {}, function (work) {
			step(work[0], work[1], work[2], true);
		});
	}

	function processMessage(msg) {
		send('/msg', msg, function (work) {
			step(work[0], work[1], work[2]);
		});
	}


	function render(timestamp) {
		
		// commands are always processed first.
		if (command_queue.length > 0) { // could we do all at once in one frame??
			var cmd = command_queue.shift();
			//console.log("Processing command: " + JSON.stringify(cmd));
			processMessage(cmd);
		}
		else if (event_queue.length > 0) {
			var event = event_queue.shift();
			
			while (event && isStale(event.target)) {
				//console.log('Discarding: ' + JSON.stringify(event.result));
				event = event_queue.shift();
			}
			
			if (event) {
				//console.log('Processing event: ' + JSON.stringify(event.result));
				processMessage(event.result);
			}
			else {
				// all events turned out to be stale.
				window.requestAnimationFrame(render);
			}
		}
		else if (other_queue.length > 0) {
			processMessage(other_queue.shift());
		}
		else if (subscription_queue.length > 0) {
			processMessage(subscription_queue.shift());
		}
		else {
			window.requestAnimationFrame(render);
		}
	}

	function step(cmd, subs, myPatch) {
		subscribe(subs);
		patch(root(), myPatch, replacer(root().parentNode, root()));
		// commands on natives require the natives to have been built...
		// so therefore commands after patch.
		doCommand(cmd);
	}

	function send(url, message, handle) {
		$.get(url, message, handle, 'json').always(function () {
			// request the frame after work has been done by handle
			// this ensures "synchronous" processing of messages
			window.requestAnimationFrame(render);
		});
	}

	function root() {
		return document.getElementById('root');
	}

	function nodeType(node) {
		for (var type in node) { break; }
		return type;
	}

	// Execute commands, and schedule the result on the command queue.
	function doCommand(cmd) {
		switch (nodeType(cmd)) {
		
		case 'random':
			var random = Math.floor(Math.random() * (cmd.random.to - cmd.random.from + 1)) + cmd.random.from;
			scheduleCommand(cmd.random.handle.handle, {type: 'integer', intVal: random});
			break;
			
		case 'batch':
			for (var i = 0; i < cmd.batch.commands.length; i++) {
				doCommand(cmd.batch.commands[i]);
			}
			break;
			
		default: 
			for (var k in builders) {
				if (builders.hasOwnProperty(k)) {
					builders[k].doCommand(cmd);
				}
			}
		}
	}

	// Initialize a subscription of the provided type, returning
	// a closure to cancel it when unsubscribing.
	function installSubscription(sub) {
		switch (nodeType(sub)) {
		
		case 'timeEvery':
			var timer = setInterval(function() {
				var data = {type: 'integer', intVal: (new Date().getTime() / 1000) | 0};
				scheduleSubscription(sub.timeEvery.handle.handle, data); 
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
			subscriptions[id] = installSubscription(sub);
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

	/*
	 * A user event may become stale when
	 * - 1. its dom (or any parent) is removed between the time of queueing the event, and 
	 *   removing it from the queue in render, OR
	 * - 2. the event handler has been removed from before removing event from the queue 
	 *   (such stale events are discarded in in pruneEventQueue)
	 */
	
	function isStale(dom) {
		if (dom === null) {
			return true;
		}
		if (dom === document) {
			return false;
		}
		return isStale(dom.parentNode);
	}
	
	function pruneEventQueue(type, dom) {
		var i = 0;
		while (i < event_queue.length) {
			var event = event_queue[i];
			if (event.type === type && event.target === dom) {
				event_queue.splice(i, 1);
				i--;
			}
			i++;
		}
	}
	
	
	function scheduleEvent(event, handle, data) {
		var result = makeResult(handle, data);
		event_queue.push({type: event.type, target: event.target, result: result});
	}

	function scheduleCommand(handle, data) {
		command_queue.push(makeResult(handle, data));
	}

	function scheduleOther(handle, data) {
		other_queue.push(makeResult(handle, data));
	}

	function scheduleSubscription(handle, data) {
		subscription_queue.push(makeResult(handle, data));
	}

	
	function makeResult(handle, data) {
		var result = {id: handle.id};
		if (handle.maps) {
			result.maps = handle.maps.join(';'); 
		}
		for (var k in data) {
			if (data.hasOwnProperty(k)) {
				result[k] = data[k];
			}
		}
		return result;
	}

	// This function returns an event handler closure, which, when the event
	// happens, schedules it on the queue, interpreting event data according
	// to the decoder's type. 
	// This needs adaptation if new kinds of data are required. 
	function dec2handler(decoder) {
		switch (nodeType(decoder)) {
		
		case 'succeed':
			return function (event) {	
				// TODO: change 'nothing' to 'ok'
				scheduleEvent(event, decoder.succeed.handle.handle, {type: 'nothing'});
			};
			
		case 'targetValue':
			return function (event) {
				scheduleEvent(event, decoder.targetValue.handle.handle, 
						{type: 'string', strVal: event.target.value});
			};
			
		case 'targetChecked':
			return function (event) {	
				scheduleEvent(event, decoder.targetChecked.handle.handle, 
						{type: 'boolean', boolVal: event.target.checked});
			};
			
		}
	}
	
	function patchThis(dom, edits, attach) {
		edits = edits || [];

		for (var i = 0; i < edits.length; i++) {
			var edit = edits[i];
			var type = nodeType(edit);

			switch (type) {
			
			case 'replace':
				build(edit[type].html, attach);

			case 'setText': 
				dom.nodeValue = edit[type].contents;
				break;			
				
			case 'removeNode': 
				dom.removeChild(dom.lastChild);
				break;
				
			case 'appendNode':
				build(edit[type].html, function (kid) { dom.appendChild(kid); });
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
				delete dom[edit[type].name];
				break;
				
			case 'removeEvent': 
				var key = edit[type].name;
				var handler = dom.salix_handlers[key];
				dom.removeEventListener(key, handler);
				pruneEventQueue(key, dom);
				break;
				
			default: 
				throw 'unsupported edit: ' + JSON.stringify(edit);
				
			}
		}
	}
	
	function replace(dom, newDom) {
		dom.parentNode.replaceChild(newDom, dom);
	}

	function replacer(dom, oldKid) {
		return function (newKid) {
			dom.replaceChild(newKid, oldKid);
		}
	}
	
	function patch(dom, tree, attach) {
		if (dom.salix_native) {
			dom.salix_native.patch(tree.patch.edits, attach)
		} 
		else {
			patchThis(dom, tree.patch.edits, attach);
		}
		
		var patches = tree.patch.patches || [];
		for (var i = 0; i < patches.length; i++) {
			var p = patches[i];
			var kid = dom.childNodes[p.patch.pos];
			if (kid === undefined) {
				console.log("BANG!");
			}
			patch(kid, p, replacer(dom, kid));
		}
		
	}

	// ensure that only one handler exists for any event type
	function withCleanListeners(dom, key, handler) {
		var allHandlers = dom.salix_handlers || {};
		if (allHandlers.hasOwnProperty(key)) {
			dom.removeEventListener(key, allHandlers[key]);
			pruneEventQueue(key, dom);
		}
		allHandlers[key] = handler;
		dom.salix_handlers = allHandlers;
		return handler;
	}

	
	
	function build(vdom, attach) {
	    if (vdom.txt) {
	        attach(document.createTextNode(vdom.txt.contents));
	        return;
	    }

	    var type = nodeType(vdom);
	    var vattrs = vdom[type].attrs || {};
	    var vprops = vdom[type].props || {};
	    var vevents = vdom[type].events || {};

	    if (vdom.native) {
	    	var native = vdom.native;
	    	builders[native.kind].build(attach, native.id, vattrs, vprops, vevents, native.extra);
	    	return;
	    }

	    // an element
	    
	    var elt = vprops.namespace != undefined
	            ? document.createElementNS(vprops.namespace, vdom.element.tagName)
	            : document.createElement(vdom.element.tagName);
	    
	    updateAttrsPropsAndEvents(elt, vattrs, vprops, vevents);       
	    
	    attach(elt);
	    for (var i = 0; i < vdom.element.kids.length; i++) {
	    	build(vdom.element.kids[i], function (kid) { elt.appendChild(kid); });
	    }
	    
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
	
	return {start: start, 
			registerNative: registerNative,
			build: build,
			nodeType: nodeType,
			scheduleEvent: scheduleEvent,
			scheduleSubscription: scheduleSubscription,
			scheduleOther: scheduleOther,
			scheduleCommand: scheduleCommand};
}



