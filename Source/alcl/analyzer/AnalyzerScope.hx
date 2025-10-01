package alcl.analyzer;

@:structInit
class AnalyzerScope {

    public var functions: Array<AnalyzerFunction> = [];
    public var variables: Array<AnalyzerVariable> = [];
    public var currentFunction: AnalyzerFunction = null;

    public function findFunction(name: String): AnalyzerFunction {
        for (f in functions) {
            if (f.name == name) {
                return f;
            }
        }
        return null;
    }

    public function findVariable(name: String): AnalyzerVariable {
        for (v in variables) {
            if (v.name == name) {
                return v;
            }
        }
        return null;
    }

    public function copy(): AnalyzerScope {
        return {
            functions: this.functions.copy(),
            variables: this.variables.copy(),
            currentFunction: this.currentFunction
        };
    }

    public function setCurrentFunction(func: AnalyzerFunction): AnalyzerScope {
        currentFunction = func;
        return this;
    }

}
