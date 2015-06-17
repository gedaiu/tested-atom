linterPath = atom.packages.getLoadedPackage('linter').path
Linter = require "#{linterPath}/lib/linter"
fs = require 'fs'
TestedErrors = require './tested-errors'

class LinterTested extends Linter

	@syntax: 'source.d'

	constructor: (editor) ->
		super(editor)

	moduleName: (filePath, callback) ->
		fs.readFile(filePath, 'utf8', (err,data) ->
			modulePattern = new RegExp('module (([a-z]|\.)*);', 'i');
			result = data.split modulePattern

			callback result[1]
		);


	lintFile: (filePath, callback) ->
		parent = this

		@moduleName filePath, (module) ->
			messages = []
			errors = TestedErrors.get(module)

			messages = for i, error of errors
				{
					line: error.line,
					col: 0,
					level: 'error',
					message: error.msg,
					linter: "tested",
					range: parent.computeRange({
						line: error.line,
						col: 1
					})
				}

			callback messages

module.exports = LinterTested
