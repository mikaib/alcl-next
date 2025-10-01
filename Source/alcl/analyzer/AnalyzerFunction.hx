package alcl.analyzer;
import alcl.parser.NodeInfo;

@:structInit
class AnalyzerFunction {
    public var name: String;
    public var remappedName: String = "";
    public var module: Module;
    public var parameters: Array<AnalyzerParameter> = [];
    public var returnType: AnalyzerType;
    public var info: NodeInfo;
    public var metas: Array<AnalyzerMeta> = [];
    public var isExtern: Bool = false;

    @:to
    public function toString(): String {
        return "AnalyzerFunction(" + name + ", " + parameters.map(p -> p.toString()).join(", ") + "): " + returnType.toString() + ')';
    }
}
