# tested package

This package adds support for unit tests ran with dub, the Dlang package manager.

## How to use it

In order to use this plugin you need to add ![tested](http://code.dlang.org/packages/tested)
package as a dependency in your dub.json. Once you can run your tests with tested
you can toggle this plugin and run the test with tested:run

By default you will use the ConsoleTestResultWriter class to write result but if
you need to have better results, you can use the ![AtomTestResultWriter](http://code.dlang.org/packages/tested)
with a custom ![main file](https://github.com/D-Programming-Language/dub/wiki/Cookbook#creating-a-custom-main-for-the-test-build)

![A screenshot of your package](https://f.cloud.github.com/assets/69169/2290250/c35d867a-a017-11e3-86be-cd7c5bf3ff9b.gif)
