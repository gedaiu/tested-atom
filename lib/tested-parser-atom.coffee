EventEmitter = require('events').EventEmitter



module.exports =
class TestedParserAtom extends EventEmitter

	parse: (line) ->
		parts = line.split ':'

		if(parts[0] == "ID")
			@emit("id", parts[1])

		else if(parts[0] == "NAME" && parts[1] != "")
			@emit("name", parts[1])

		else if(parts[0] == "RESULT")
			@emit("result", parts[1])

		else if(parts[0] == "DURATION")
			@emit("duration", parseFloat(parts[1]))