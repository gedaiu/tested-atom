# tested package

This package adds support for unit tests ran with dub, the Dlang package manager.

![A screenshot](http://szabobogdan.com/tested.gif)

## How to use it

In order to use this plugin you need to add [tested](http://code.dlang.org/packages/tested)
package as a dependency in your dub.json. Once you can run your tests with tested
you can toggle this plugin and run the test with tested:run

By default you will use the ConsoleTestResultWriter class to write result but if
you need to have better results, you can use the [AtomTestResultWriter](http://code.dlang.org/packages/tested-atom)
with a custom [main file](https://github.com/D-Programming-Language/dub/wiki/Cookbook#creating-a-custom-main-for-the-test-build)

## Dependencies

### Toolbar

![Toolbar screenshot](http://szabobogdan.com/toolbar.png)

If you want to add a test button to your workspace, you can install
[tool-bar](https://atom.io/packages/tool-bar) plugin.

### Linter

![Linter screenshot](http://szabobogdan.com/linter.png)

To see the test fail messages, you can install the
[linter](https://atom.io/packages/linter) plugin
