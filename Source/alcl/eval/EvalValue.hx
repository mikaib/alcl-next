package alcl.eval;

import alcl.analyzer.AnalyzerType;

@:structInit
class EvalValue {
    public var value: Dynamic;
    public var type: AnalyzerType;

    @:to
    public function toString(): String {
        return '(${type.toHumanReadableString()}) ${Std.string(value)}';
    }
}
