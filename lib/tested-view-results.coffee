{$, View} = require 'atom-space-pen-views'

module.exports =
class TestedViewResults extends View
	@content: ->
		@div class: 'tested-results', outlet: "results", =>

	initialize: (state) ->
		@expansionStates ?= {}
		@handleEvents()

	handleEvents: ->
		@on 'mousedown', '.test', (e) =>
			@jump(e)

		@on 'mousedown', '.module', (e) =>
			@showModule(e)

	clear: ->
		$(@element).html ""

	update: (tests) ->
		@clear()
		$(@element).append(@createModules(tests))
		@updateParentFailed()

	createLevel: (tests, name, id) ->
		list = for key, value of tests
			if value.name then @createTest value else @createLevel(tests[key], key, id + "." + key)

		open = " open" if @expansionStates[id]
		open ?= ""

		"<li data-id='" + id + "' class='container" + open + "'><span class='module test-pass icon icon-file-directory'>#{name}</span><ol>" + list.join("") + "</ol></li>"

	createModules: (tests) ->
		list = for key, value of tests
			"<ol>" + @createLevel(tests[key], key, key) + "</ol>"

		list.join("")

	createTest: (test) ->
		if test.result == "PASS"
			"<li><span data-module='#{test.module}' data-line='#{test.line}' class='test test-pass icon icon-check'>#{test.name}</span></li>"

		else if test.result == "FAIL"
			"<li><span data-module='#{test.module}' data-line='#{test.line}' class='test test-fail icon icon-x'>#{test.name}</span></li>"
		else
			"<li><span data-module='#{test.module}' data-line='#{test.line}' class='test icon icon-triangle-right'>#{test.name}</span></li>"

	updateParentFailed: ->
		$(".test-fail").each ->
			parent = $(this).parent();

			while parent.is("ol, li")
				parent.children().removeClass("test-pass").addClass "test-fail"
				parent = parent.parent()

	jump: (e) ->
		e.stopPropagation()
		element = $(e.target)
		@onJump(element.attr("data-module"), parseInt(element.attr("data-line")))

	showModule: (e) ->
		e.stopPropagation()
		parent = $(e.target).parent()

		parent.toggleClass("open")

		id = parent.attr("data-id")

		if(parent.is(".open"))
				@expansionStates[id] = true
		else
				delete @expansionStates[id]
