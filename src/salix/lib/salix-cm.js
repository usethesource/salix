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

function registerCodeMirror(salix) {
	
	var codeMirrors = {};
	
	function parseSimpleMode(mode) {
		
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
		
		return jsMode;
	}
	
	salix.Decoders.codeMirrorChange = function (args) {
		return function (editor, change) {
			return {type: 'codeMirrorChange', 
				fromLine: change.from.line, fromCol: change.from.ch,
				toLine: change.to.line, toCol: change.to.ch,
				text: change.text.join('\n'),
				removed: change.removed.join("\n")};
		};
	};
	
	salix.Decoders.cursorActivity = function (args) {
		return function (editor) {
			var position = editor.getCursor();
			var line = position.line;
			var token = editor.getTokenAt(position);
			return  {type: 'cursorActivity', line: line, start: token.start, 
				end: token.end, string: token.string, tokenType: token.type};
		};
	};
	
	function codeMirror(attach, id, attrs, props, events, extra) {
		var cm = CodeMirror(function(elt) { attach(elt); }, {});
		
		codeMirrors[id] = cm;

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
				var handler = salix.getNativeHandler(events[key]);
				myHandlers[key] = handler;
				cm.on(key, handler);
			}
		}

		setTimeout(function() {
            cm.refresh();
        }, 100);
		
		
		function patch(edits, attach) {
			edits = edits || [];

			for (var i = 0; i < edits.length; i++) {
				var edit = edits[i];
				var type = salix.nodeType(edit);

				switch (type) {
				
				case 'replace':
					salix.build(edit[type].html, attach);
					break;

				case 'setProp': 
					var key = edit[type].name;
					var val = edit[type].val;
					if (key === 'value') {
						// ignore
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
					var handler = salix.getNativeHandler(edit[type].handler);
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
	}
	
	function doCommand(cmd) {
		// TODO
	}
	
	salix.registerNative('codeMirror', codeMirror);
};