module.exports =
class TestedTest

	getDefaultTestName: (id) ->
		parts = id.split '.'
		parts[parts.length - 1]

	getModule: (id) ->
		parts = id.split '.'
		parts[0...parts.length-1].join "."

	getLine: (id) ->
		name = @getDefaultTestName id
		start = name.indexOf "L"
		name = name[start...]

		end = name.indexOf "_"

		parseInt name[1...end]

	constructor: (id) ->
		@id = id
		@name = @getDefaultTestName id
		@module = @getModule id
		@line = @getLine id
		@result = ""
		@duration = -1
