

function registerXTerm(salix) {
	
	var xterms = {};
	
	function val2result(x) {
		if (typeof x === 'undefined') {
			return {type: 'nothing'};
		}
		if (typeof x === 'string') {
			return {type: 'string', value: x}
		}
		if (typeof x === 'number') {
			return {type: 'integer', value: x};
		}
		if (typeof x === 'boolean') {
			return {type: 'boolean', value: x};
		}
	}
	
	salix.Commands.getOption = function(args) {
		var term = xterms[args.id];
		return val2result(term.getOption(args.key));
	}
	// TODO: etc.
	
	function doCommand(cmd) {
		var type = cmd.command.name;
		var term = xterms[cmd.command.args.id];
		
		if (!term) {
			return;
		}
		
		switch (type) {
		
		case 'getOption':
			schedule(schedule, term.getOption(cmd.getOption.key));
			break

		case 'setOption':
			term.setOption(cmd.command.args.key, cmd.command.args.val);
			schedule(cmd, undefined);
			break

		case 'refresh':
			term.refresh(cmd.command.args.start, cmd.command.args.end, cmd.command.args.queue);
			schedule(cmd, undefined);
			break

		case 'resize':
			term.resize(cmd.command.args.x, cmd.command.args.y);
			schedule(cmd, undefined);
			break;

		case 'scrollDisp':
			term.scrollDisp(cmd.command.args.n);
			schedule(cmd, undefined);
			break;

		case 'scrollPages':
			term.scrollPages(cmd.command.args.n);
			schedule(cmd, undefined);
			break;

		case 'write':
			term.write(cmd.command.args.text);
			schedule(cmd, undefined);
			break;
			
		case 'writeln':
			term.writeln(cmd.command.args.text);
			schedule(cmd, undefined);
			break;
		
		default:
			term[type]();
			schedule(cmd, undefined);
		}
	}
	
	function scheduleEvent(hnd, result) {
		salix.scheduleOther(hnd.handler.handle.handle, result);
	}
	
	function dec2handler(hnd) {
		var type = hnd.handler.name;
		switch (type) {
		
		case 'eventData':
			return function (data) {
				scheduleEvent(hnd, val2result(data));
			};
			
		case 'keyName':
			return function (key, event) {
				scheduleEvent(hnd, val2result(key)); 
			};
		
		case 'startEnd':
			return function (data) {
				scheduleEvent(hnd, 
					{type: 'int-int', value1: data.start, value2: data.end}); 
			};
		
		case 'colsRows':
			return function (data) {
				scheduleEvent(hnd, 
					{type: 'int-int', value1: data.cols, value2: data.rows}); 
			};
		
		case 'ydisp':
			return function (n) {
				scheduleEvent(hnd, val2result(n)); 
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