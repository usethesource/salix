

function registerXTerm(salix) {
	
	var xterms = {};
	
	function val2result(x) {
		if (typeof x === 'undefined') {
			return {type: 'nothing'};
		}
		if (typeof x === 'string') {
			return {type: 'string', strVal: x}
		}
		if (typeof x === 'number') {
			return {type: 'integer', intVal: x};
		}
		if (typeof x === 'boolean') {
			return {type: 'boolean', boolVal: x};
		}
	}
	
	function schedule(type, cmd, value) {
		salix.scheduleCommand(cmd[type].handle.handle, val2result(value));
	}
	
	function doCommand(cmd) {
		var type = salix.nodeType(cmd);
		var term = xterms[cmd[type].id];
		
		if (!term) {
			return;
		}
		
		switch (type) {
		
		case 'getOption':
			schedule(type, schedule, term.getOption(cmd.getOption.key));
			break

		case 'setOption':
			term.setOption(cmd.setOption.key, cmd.setOption.val);
			schedule(type, cmd, undefined);
			break

		case 'refresh':
			term.refresh(cmd.refresh.start, cmd.refresh.end, cmd.refresh.queue);
			schedule(type, cmd, undefined);
			break

		case 'resize':
			term.resize(cmd.resize.x, cmd.resize.y);
			schedule(type, cmd, undefined);
			break;

		case 'scrollDisp':
			term.scrollDisp(cmd.scrollDisp.n);
			schedule(type, cmd, undefined);
			break;

		case 'scrollPages':
			term.scrollPages(cmd.scrollPages.n);
			schedule(type, cmd, undefined);
			break;

		case 'write':
			term.write(cmd.write.text);
			schedule(type, cmd, undefined);
			break;
			
		case 'writeln':
			term.writeln(cmd.writeln.text);
			schedule(type, cmd, undefined);
			break;
		
		default:
			term[type]();
			schedule(type, cmd, undefined);
		}
	}
	
	function scheduleEvent(type, dec, result) {
		salix.scheduleOther(dec[type].handle.handle, result);
	}
	
	function dec2handler(decoder) {
		var type = salix.nodeType(decoder);
		switch (type) {
		
		case 'eventData':
			return function (data) {
				scheduleEvent(type, decoder, val2result(data));
			};
			
		case 'keyName':
			return function (key, event) {
				scheduleEvent(type, decoder, val2result(key)); 
			};
		
		case 'startEnd':
			return function (data) {
				scheduleEvent(type, decoder, 
					{type: 'int-int', intVal1: data.start, intVal2: data.end}); 
			};
		
		case 'colsRows':
			return function (data) {
				scheduleEvent(type, decoder, 
					{type: 'int-int', intVal1: data.cols, intVal2: data.rows}); 
			};
		
		case 'ydisp':
			return function (n) {
				scheduleEvent(type, decoder, val2result(n)); 
			};

		}
	}
	
	function myXterm(attach, id, attrs, props, events, extra) {
		var rows = parseInt(props['rows']);
		var cols = parseInt(props['cols']);
		var term = new Terminal({
			cols: cols,
			rows: rows,
			cursorBlink: props['cursorBlink'] === 'true'
		});
		
		xterms[id] = term;
		
		var div = document.createElement('div');
		attach(div);

		term.open(div);

		var myHandlers = {};
		
		for (var key in events) {
			// TODO: code is dupe of setEvent
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

				case 'setAttr':
					term.element.setAttribute(edit[type].name, edit[type].val);
					break;
					
				case 'setProp':
					var key = edit[type].name;
					if (key === 'cols') {
						term.resize(parseInt(props.cols), term.y);
					}
					else if (key === 'rows') {
						term.resize(term.y, parseInt(props.rows));
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

				case 'removeAttr': 
					term.element.removeAttribute(edit[type].name);
					break;

				case 'removeProp':
					if (key === 'cursorBlink') {
						cm.setOption(key, false);
					}
					// else do nothing
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
		
        
		div.salix_native = {patch: patch};
		return div;
	}
	
	salix.registerNative('xterm', {build: myXterm, doCommand: doCommand});
};