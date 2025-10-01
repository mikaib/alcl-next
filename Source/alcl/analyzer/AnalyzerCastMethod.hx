package alcl.analyzer;

@:structInit
class AnalyzerCastMethod {
    public var from: AnalyzerType;
    public var to: AnalyzerType;
    public var handler: (AnalyzerConstraint, AnalyzerSolver) -> Bool;
}
