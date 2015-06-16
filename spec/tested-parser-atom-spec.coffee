TestedParserAtom = require '../lib/tested-parser-atom'

describe "TestedParserAtom", ->
	it "parse ID line", ->
		parser = new TestedParserAtom()

		parser.on("id", (id) ->
			expect(id).toBe("project.module.__unittestL321_6")
		)

		parser.parse("ID:project.module.__unittestL321_6")

	it "parse NAME line", ->
		parser = new TestedParserAtom()

		parser.on("name", (name) ->
			expect(name).toBe("test")
		)

		parser.parse("NAME:test")

	it "parse DURATION line", ->
		parser = new TestedParserAtom()

		parser.on("duration", (duration) ->
			expect(duration).toBe(100)
		)

		parser.parse("DURATION:100")

	it "parse RESULT line", ->
		parser = new TestedParserAtom()

		parser.on("result", (result) ->
			expect(result).toBe("PASS")
		)

		parser.parse("RESULT:PASS")
