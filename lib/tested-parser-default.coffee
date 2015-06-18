EventEmitter = require('events').EventEmitter



module.exports =
class TestedParserDefault extends EventEmitter

	parse: (line) ->
		pattern = /(.*)(PASS|FAIL) "(.*)" \((.*)\) after (.*) s/i
		parts = line.split pattern

		parts = parts[2...] if parts.length > 0 and (parts[2] == "PASS" or parts[2] == "FAIL")

		if(parts.length >= 4 and (parts[0] == "PASS" or parts[0] == "FAIL"))
			@emit("id", parts[2])
			@emit("name", parts[1]) if parts[1] != ""
			@emit("result", parts[0])
			@emit("duration", parseFloat(parts[3]))
		else
			@emit("console", line)

	parseError: (line)->
		@emit("console error", line);
