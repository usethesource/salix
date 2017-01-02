
/*
 * CodeMirror sometimes generates 2 events in a row (very quickly)
 * As a result, they're flushed... We need an async event queue, which
 * will never be flushed. This is compatible with the idea that natives
 * manage their own state more or less. 
 */

function registerCodeMirror(salix) {
	
	
	function parseSimpleMode(mode) {
		console.log(JSON.stringify(mode, 2));
		
		var jsMode = {};
		for (var i = 0; i < mode.mode.states.length; i++) {
			var state = mode.mode.states[i]
			var name = state.state.name;
			jsMode[name] = []; 
			for (var j = 0; j < state.state.rules.length; j++) {
				var rule = state.state.rules[i];
				var token = rule.rule.tokens.length > 1 
					? rule.rule.tokens : rule.rule.tokens[0];
				jsMode[name].push({regex: new RegExp(rule.rule.regex),
						token: token});
			}
		}
		console.log(JSON.stringify(jsMode, 2));
		
		return jsMode;
	}
	
	
	function dec2handler(decoder) {
		switch (salix.nodeType(decoder)) {
		
		// for now: schedule on the other queue, because we don't 
		// want to ever discard events (code mirror manages own state).
		
		case 'codeMirrorChange':
			return function (editor, change) {
				salix.scheduleOther(decoder.codeMirrorChange.handle.handle,  {
					type: 'codeMirrorChange', 
					fromLine: change.from.line, fromCol: change.from.ch,
					toLine: change.to.line, toCol: change.to.ch,
					text: change.text.join('\n'),
					removed: change.removed.join("\n")
				});
			};
			
		case 'cusorActivity':
			return function (editor) {
				var position = editor.getCursor();
				var line = position.line;
				var token = editor.getTokenAt(position);
				salix.scheduleOther(decoder.cursorActivity.handle.handle, 
					{type: 'cursorActivity', line: line, start: token.start, 
					end: token.end, string: token.string, tokenType: token.type});
			};
		
		}
	}
	
	function codeMirror(parent, props, events, extra) {
		var cm = CodeMirror(parent, {});
		// for remove event.
		var myHandlers = {};
		
		if (extra && extra.mode) {
			var mode = parseSimpleMode(extra.mode);
			CodeMirror.defineSimpleMode(extra.mode.mode.name, mode);
		}

		for (var key in props) {
			// todo: this logic is shared with setProp
			if (props.hasOwnProperty(key)) {
				var val = props[key];
				
				if (key === 'value') {
					cm.getDoc().setValue(val);
				}
				if (key == 'width') {
					cm.setSize(val, null);
				}
				else if (key === 'height') {
					cm.setSize(null, val);
				}
				else if (key === 'style') {
					cm.getWrapperElement().style = val;
				}
				else if (key === 'simpleMode') {
					// do defineSimpleMode
				}
				else {
					cm.setOption(key, val);
				}
			}
		}
		
		for (var key in events) {
			// TODO: shared with setEvent
			if (events.hasOwnProperty(key)) {
				var handler = dec2handler(events[key]);
				myHandlers[key] = handler;
				cm.on(key, handler);
			}
		}

		setTimeout(function() {
            cm.refresh();
        }, 100);
		
		
		function patch(edits) {
			edits = edits || [];

			for (var i = 0; i < edits.length; i++) {
				var edit = edits[i];
				var type = salix.nodeType(edit);

				switch (type) {
				
				case 'replace':
					return salix.build(edit[type].html);

				case 'setProp': 
					var key = edit[type].name;
					var val = edit[type].val;
					if (key === 'value') {
						// ignore value changes
						
//						if (cm.getValue() !== val) {
//							var hasChange = myHandlers.hasOwnProperty('change');
//							if (hasChange) { 
//								cm.off('change', myHandlers.change);	
//							}
//							cm.setValue(val);
//							if (hasChange) {
//								cm.on('change', myHandlers.change);
//							}
//						}
						
					}
					else if (key === 'width') {
						cm.setSize(val, null);
					}
					else if (key === 'height') {
						cm.setSize(null, val);
					}
					else if (key === 'style') {
						cm.getWrapperElement().style = val;
					}
					else {
						cm.setOption(key, val);
					}
					break;
					
				case 'setEvent': 
					var key = edit[type].name;
					var handler = dec2handler(edit[type].handler);
					myHandlers[key] = handler;
					cm.on(key, handler);
					break
				
				case 'removeProp':
					var key = edit[type].name;
					if (key === 'width' || key === 'height') {
						// doesn't actually revert it.
						cm.setSize(null, null);
					}
					else if (key === 'style') {
						cm.getWrapperElement().style = '';
					}
					else {
						cm.setOption(key, CodeMirror.defaults[key]);
					}
					break;
					
				case 'removeEvent':
					var key = edit[type].name
					cm.off(key, myHandlers[key]);
					delete myHandlers[key];
					break;
					
				default: 
					throw 'unsupported edit: ' + JSON.stringify(edit);
					
				}
			}
		}
		
		var dom = cm.getWrapperElement();
		dom.salix_native = {patch: patch};
		return dom;
	}
	
	salix.registerNative('codeMirror', codeMirror);
};