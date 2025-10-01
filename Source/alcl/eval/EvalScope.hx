package alcl.eval;
import alcl.analyzer.AnalyzerType;

@:structInit
class EvalScope {

    public var functions: Array<EvalFunction> = [];
    public var variables: Array<EvalVariable> = [];
    public var returnValue: EvalValue = { type: AnalyzerType.TVoid, value: 0 };

    public function findFunction(name: String): EvalFunction {
        for (f in functions) {
            if (f.desc.name == name) {
                return f;
            }
        }
        return null;
    }

    public function findVariable(name: String): EvalVariable {
        for (v in variables) {
            if (v.name == name) {
                return v;
            }
        }
        return null;
    }

    public function copy(): EvalScope {
        return {
            functions: this.functions.copy(),
            variables: this.variables.copy()
        };
    }

}
