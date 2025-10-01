package alcl;

import alcl.tokenizer.Tokenizer;
import alcl.parser.Parser;
import alcl.cgen.GeneratorContext;
import alcl.analyzer.AnalyzerFunction;
import alcl.analyzer.AnalyzerTyper;
import alcl.parser.AST;

@:structInit
class Module {
    public var name: String;
    public var path: String;
    public var tokenizer: Tokenizer;
    public var parser: Parser;
    public var typer: AnalyzerTyper;
    public var typedAst: AST;
    public var functions: Array<AnalyzerFunction> = [];
    public var imports: Array<Module> = [];
    public var includes: Array<String> = [];

    public function getNativeSource(genCtx: GeneratorContext): String {
        return genCtx.getNativeSource(this);
    }

    public function getNativeHeader(genCtx: GeneratorContext): String {
        return genCtx.getNativeHeader(this);
    }

    public function getProjectPrefix(): String {
        var projName = parser.getContext().options.projectName;
        return projName == "" ? "" : projName + "_";
    }

    public function getPathHeader(): String {

        return './${getProjectPrefix() + name}.h';
    }

    public function getPathSource(): String {
        return './${getProjectPrefix() + name}.c';
    }

    public function getSafeName(v: String = ""): String {
        return getProjectPrefix() + StringTools.replace(name, "/", "_").toLowerCase() + (if (v != "") "_" + v else "");
    }

    public function addImport(moduleName: String): Void {
        var ctx = parser.getContext();
        var mod = ctx.module(moduleName);

        if (mod != null && !imports.contains(mod)) {
            imports.push(mod);
        }
    }

    @:to
    public function toString(): String {
        return "Module(" + name + ", " + path + ")";
    }
}
