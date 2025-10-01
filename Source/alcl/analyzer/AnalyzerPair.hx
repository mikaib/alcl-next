package alcl.analyzer;

import alcl.parser.Node;

@:structInit
class AnalyzerPair {
    public var node: Node;
    public var type: AnalyzerType;

    public static function fromNode(node: Node, type: AnalyzerType): AnalyzerPair {
        return { node: node, type: type };
    }

    public static function fromType(type: AnalyzerType): AnalyzerPair {
        return { node: null, type: type };
    }

    public function copy(): AnalyzerPair {
        return {
            node: node,
            type: type.copy()
        };
    }

    @:to
    public function toString(): String {
        return "AnalyzerPair(" + type.toString() + ")";
    }

}
