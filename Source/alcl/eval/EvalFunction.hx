package alcl.eval;

import alcl.analyzer.AnalyzerFunction;
import alcl.parser.AST;

@:structInit
class EvalFunction {
    public var desc: AnalyzerFunction;
    public var scope: EvalScope;
    public var body: AST;
    public var patchedImpl: Dynamic;
}
