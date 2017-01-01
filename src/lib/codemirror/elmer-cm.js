

function registerCodeMirror(elmer) {
	
	function dec2handler(decoder) {
		switch (elmer.nodeType(decoder)) {
		
		case 'change':
			return function (editor, change) {
				elmer.scheduleEvent(events.change,  {
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
				elmer.scheduleEvent(events.cursorActivity,  {line: line, start: token.start, 
					end: token.end, string: token.string, tokenType: token.type});
			};
		
		}
	}
	
	function codeMirror(parent, props, events) {
		var cm = CodeMirror(parent, {});

		for (var key in props) {
			if (props.hasOwnProperty(key)) {
				if (key === 'value') {
					cm.getDoc().setValue(props.value);
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

		setTimeout(function() {
            cm.refresh();
        }, 100);
		
		
		// for remove event.
		var myHandlers = {};
		
		function patch(edits) {
			edits = edits || [];

			for (var i = 0; i < edits.length; i++) {
				var edit = edits[i];
				var type = nodeType(edit);

				switch (type) {
				
				case 'replace':
					return elmer.build(edit[type].html);

				case 'setProp': 
					var key = edit[type].name;
					var val = edit[type].val;
					if (key == 'width') {
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
		dom.elmer_native = {patch: patch};
		return dom;
	}
	
	elmer.registerNative('codeMirror', codeMirror);
};