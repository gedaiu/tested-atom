TestedParserAtom = require '../lib/tested-parser-default'

describe "TestedParserDefault", ->
	it "parse PASS line", ->
		parser = new TestedParserAtom()

		parser.on("id", (id) ->
			expect(id).toBe("program.module.__unittestL321_6")
		)

		parser.on("name", (name) ->
			expect(name).toBe("test")
		)

		parser.on("duration", (duration) ->
			expect(duration).toBe(0.000006)
		)

		parser.on("result", (result) ->
			expect(result).toBe("PASS")
		)

		parser.parse('PASS "test" (program.module.__unittestL321_6) after 0.000006 s')
