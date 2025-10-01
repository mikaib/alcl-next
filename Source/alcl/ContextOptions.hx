package alcl;

import haxe.io.Path;

@:structInit
class ContextOptions {
    public var roots: Array<String> = [];
    public var defines: Map<String, Dynamic> = [];
    public var main: String = "main";
    public var projectName: String = "alcl";
    public var outputDirectory: String = Path.join([Sys.getCwd(), "out"]);
}
