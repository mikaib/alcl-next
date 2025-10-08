package alcl;

import haxe.io.Path;

@:structInit
class ContextOptions {
    public var roots: Array<String> = [];                                  // all roots of the project, including the stdlib
    public var defines: Map<String, Dynamic> = [];                         // defines to pass to the preprocessor
    public var main: String = "main";                                      // the main module to compile
    public var projectName: String = "alcl";                               // the prefix for functions, can be used to prevent name clashes
    public var outputDirectory: String = Path.join([Sys.getCwd(), "out"]); // place for the binary and C source files
    public var greedySolver: Bool = false;                                 // will make the solver "greedy" and force it to solve dependant types if it cannot solve otherwise
}
