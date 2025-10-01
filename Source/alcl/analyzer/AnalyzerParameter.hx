package alcl.analyzer;

@:structInit
class AnalyzerParameter {
    public var name: String;
    public var type: AnalyzerType;

    @:to
    public function toString(): String {
        return name + ": " + type.toString();
    }
}
