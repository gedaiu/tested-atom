{CompositeDisposable} = require 'atom'
ChildProcess = require 'child_process'
TestedTest = require './tested-test'
TestedErrors = require './tested-errors'

module.exports =
class TestedRunner
	tests: {}
	elm: null

	constructor: (parser) ->
		@parser = parser
		parent = this

		@parser.on("id", (id) ->
			parent.addError() if parent.elm?
			parent.newTest(id)
		)

		@parser.on("name", (name) ->
			parent.elm.name = name
		)

		@parser.on("result", (result) ->
			parent.elm.result = result
			parent.nrTestsSuccess += 1 if result == "PASS"
		)

		@parser.on("duration", (duration) ->
			parent.elm.duration = duration
		)

		@parser.on("error file", (filePath) ->
			parent.elm.errorFile = filePath
		)

		@parser.on("error line", (line) ->
			parent.elm.errorLine = line
		)

		@parser.on("error msg", (msg) ->
			parent.elm.errorMsg = msg
		)

		@parser.on("console", (msg) ->
			parent.onConsole(msg)
		)

		@parser.on("console error", (msg) ->
			parent.onConsoleError(msg)
		)

	addError: ->
		TestedErrors.add({
				module: @elm.module,
				line: @elm.errorLine,
				msg: @elm.errorMsg
		}) if @elm.errorMsg?

	prepareLevel: (path) ->
		level = @tests

		for i, key of path
			level[key] ?= {}
			level[key] = @elm if parseInt(i) == (path.length - 1)
			level = level[key]

	newTest: (id) ->
		@nrTests++
		@id = id

		@elm = new TestedTest(id)

		@prepareLevel id.split '.'

	parseLine: (line) ->
		@parser.parse(line)

	parseErrorLine: (line) ->
		@parser.parseError(line)

	isRunning: ->
		if @dub? then true else false

	kill: ->
		@dub.kill('SIGKILL')
		@dub = null

	run: (callback) ->
		parent = this
		@tests = {}
		@msg = ""
		@nrTests = 0
		@nrTestsSuccess = 0

		@onStart()
		TestedErrors.clear()

		dubPath = atom.config.get('tested.dubPath')
		dubArguments = [ "test" ]
		dubArguments[1..] = atom.config.get('tested.dubArguments').split " "

		@dub = ChildProcess.spawn(dubPath, dubArguments,
			cwd: atom.project.getPaths()[0],
			env: process.env
		)

		console.log("run dub:", dubPath, dubArguments);

		@dub.stdout.on('data', (data) ->
			lines = (data+"").split '\n'

			for i, line of lines
				parent.parseLine(line)

			callback(parent.tests)
		)

		@dub.stderr.on('data', (data) ->
			lines = (data+"").split '\n'

			for i, line of lines
				parent.parseErrorLine(line)
		)

		@dub.on('exit', (code) ->
			parent.dub = null

			parent.onStop code
			parent.onSuccess(parent.nrTests, parent.nrTestsSuccess)
		)
