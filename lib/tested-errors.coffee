errors = {}


module.exports =

	clear: ->
		errors = {}

	add: (elm) ->
		errors[elm.module] ?= []
		errors[elm.module].push elm

	get: (moduleName) ->
		errors[moduleName] ?= []
		return errors[moduleName]
