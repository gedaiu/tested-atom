{CompositeDisposable} = require 'atom'
ChildProcess = require 'child_process'
TestedTest = require './tested-test'

module.exports =
class TestedRunner
	tests: {}
	elm: null

	constructor: (parser) ->
		@parser = parser
		parent = this

		@parser.on("id", (id) ->
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

		dubPath = atom.config.get('tested.dubPath')
		dubArguments = [ "test" ]
		dubArguments[1..] = atom.config.get('tested.dubArguments').split " "

		@dub = ChildProcess.spawn(dubPath, dubArguments,
			cwd: atom.project.getPaths()[0],
			env: process.env
		)

		@dub.stdout.on('data', (data) ->
			lines = (data+"").split '\n'

			for i, line of lines
				parent.parseLine(line)

			callback(parent.tests)
		)

		@dub.on('exit', (code) ->
			parent.dub = null

			parent.onStop code
			parent.onSuccess(parent.nrTests, parent.nrTestsSuccess)
		)
