TestedTest = require '../lib/tested-test'

describe "TestedTest", ->
      it "set the id", ->
            test = new TestedTest("module.name.__unittestL10_343")
            expect(test.id).toBe("module.name.__unittestL10_343")

      it "parse name from id", ->
            test = new TestedTest("module.name.__unittestL10_343")
            expect(test.name).toBe("__unittestL10_343")

      it "parse module name from id", ->
            test = new TestedTest("module.name.__unittestL10_343")
            expect(test.module).toBe("module.name")

      it "parse line number from id", ->
            test = new TestedTest("module.name.__unittestL100_343")
            expect(test.line).toBe(100)
