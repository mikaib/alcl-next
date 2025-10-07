package alcl.analyzer;
import alcl.parser.NodeInfo;

@:structInit
class AnalyzerVariable {
    public var name: String;
    public var module: Module;
    public var type: AnalyzerType;
    public var info: NodeInfo;

    @:to
    public function toString(): String {
        return "AnalyzerVariable(" + name + ", " + type.toString() + ')';
    }
}
