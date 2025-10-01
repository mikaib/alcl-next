package alcl.analyzer;

@:structInit
class AnalyzerConstraint {
    public var want: AnalyzerPair;
    public var have: AnalyzerPair;
    public var explicit: Bool = false;
    public var result: AnalyzerType = AnalyzerType.TDependant;

    public function flipped(): AnalyzerConstraint {
        return {
            want: have,
            have: want,
            result: result
        };
    }

    public function copy(): AnalyzerConstraint {
        return {
            want: want.copy(),
            have: have.copy(),
            result: result.copy()
        };
    }

    @:to
    public function toString(): String {
        return "AnalyzerConstraint( " + have.toString() +  " -> " + want.toString() + " = " + result.toString() + " )";
    }

}
