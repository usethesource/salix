

function registerXTerm(salix) {
	
	function dec2handler(decoder) {
		switch (salix.nodeType(decoder)) {
		
		// for now: schedule on the other queue, because we don't 
		// want to ever discard events (code mirror manages own state).
		
		case 'eventData':
			return function (editor, change) {
				salix.scheduleOther(decoder.eventData.handle.handle,  {
					// todo
				});
			};
			
		case 'keyName':
			return function (editor) {
				salix.scheduleOther(decoder.keyName.handle.handle); // todo 
			};
		
		case 'startEnd':
			return function (editor) {
				salix.scheduleOther(decoder.startEnd.handle.handle); // todo 
			};
		
		case 'colsRows':
			return function (editor) {
				salix.scheduleOther(decoder.colsRows.handle.handle); // todo 
			};
		
		case 'ydisp':
			return function (editor) {
				salix.scheduleOther(decoder.ydisp.handle.handle); // todo 
			};
		

		}
	}
	
	function myXterm(attach, props, events, extra) {
		var rows = parseInt(props['rows']);
		var cols = parseInt(props['cols']);
		var term = new Terminal({
			cols: cols,
			rows: rows,
			cursorBlink: props['cursorBlink'] === 'true'
		});
		
        var shellprompt = '$ ';

        term.prompt = function () {
        	term.write('\r\n' + shellprompt);
        };
        
        term.on('key', function (key, ev) {
        	console.log("The key: " + key);
            var printable = (
              !ev.altKey && !ev.altGraphKey && !ev.ctrlKey && !ev.metaKey
            );

            if (ev.keyCode == 13) {
            	console.log("Adding prompt");
            	term.prompt();
            } else if (ev.keyCode == 8) {
             // Do not delete the prompt
              if (term.x > 2) {
                term.write('\b \b');
              }
            } else if (printable) {
              term.write(key);
            }
        });

        term.on('paste', function (data, ev) {
            term.write(data);
        });
        
		var myHandlers = {};
		
		for (var key in events) {
			// TODO: shared with setEvent
			if (events.hasOwnProperty(key)) {
				var handler = dec2handler(events[key]);
				myHandlers[key] = handler;
				term.on(key, handler);
			}
		}

		function patch(edits, attach) {
			edits = edits || [];

			for (var i = 0; i < edits.length; i++) {
				var edit = edits[i];
				var type = salix.nodeType(edit);

				switch (type) {
				
				case 'replace':
					return salix.build(edit[type].html, attach);

				case 'setProp':
					var key = edit[type].name;
					if (key === 'style') {
						term.element.style = edit[type].value;
					}
					else {
						term.setOption(key, val);
					}
					break;
					
				case 'setEvent': 
					var key = edit[type].name;
					var handler = dec2handler(edit[type].handler);
					myHandlers[key] = handler;
					term.on(key, handler);
					break
				
				case 'removeProp':
					if (key === 'style') {
						term.element.style = '';
					}
					else {
						cm.setOption(key, undefined);
					}
					break;
					
				case 'removeEvent':
					var key = edit[type].name
					term.off(key, myHandlers[key]);
					delete myHandlers[key];
					break;
					
				default: 
					throw 'unsupported edit: ' + JSON.stringify(edit);
					
				}
			}
		}
		
		var div = document.createElement('div');
		attach(div);

		term.open(div);
		term.prompt();
		
		//term.fit();
		//term.prompt();
//		term.prompt();
//		term.reset();
        
        
		div.salix_native = {patch: patch};
		return div;
	}
	
	salix.registerNative('xterm', myXterm);
};