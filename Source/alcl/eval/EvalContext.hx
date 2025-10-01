package alcl.eval;

import alcl.parser.AST;
import alcl.Module;
import alcl.parser.Node;
import alcl.analyzer.AnalyzerType;

class EvalContext {

    private var ast: AST;
    private var module: Module;
    private var baseScope: EvalScope;
    private var expScope: EvalScope;

    public function new(ast: AST, module: Module) {
        this.ast = ast;
        this.module = module;
        this.baseScope = {};
        this.expScope = {};

        for (imp in module.imports) {
            var c = new EvalContext(imp.typedAst, imp);
            c.run();

            baseScope = {
                functions: baseScope.functions.concat(c.getExports().functions),
                variables: baseScope.variables.concat(c.getExports().variables)
            };
        }
    }

    public function getExports(): EvalScope {
        return expScope;
    }

    public function run(): EvalValue {
        expScope = baseScope.copy();
        return execBody(ast, expScope);
    }

    public function castValue(value: EvalValue, type: AnalyzerType): EvalValue {
        var from = value.type;

        if (from.isNumeric() && type.eq(AnalyzerType.TInt)) {
            return { type: type, value: Math.floor(value.value) };
        }

        if (!from.eq(AnalyzerType.TString) && type.eq(AnalyzerType.TString)) {
            return { type: type, value: Std.string(value.value) };
        }

        return value;
    }

    public function execBody(body: AST, scope: EvalScope): EvalValue {
        var res: EvalValue = null;
        for (node in body) {
            res = execNode(node, scope);
        }
        return res;
    }

    public function execNode(node: Node, scope: EvalScope): EvalValue {
        switch (node.kind) {
            case IntegerLiteralNode(value): // we always use float because they are 64-bit in width.
                return { type: AnalyzerType.TInt, value: Std.parseFloat(value) };

            case FloatLiteralNode(value):
                return { type: AnalyzerType.TFloat, value: Std.parseFloat(value) };

            case StringLiteralNode(value):
                return { type: AnalyzerType.TString, value: value };

            case BooleanLiteralNode(value):
                return { type: AnalyzerType.TBool, value: value == "true" };

            case CCast(to):
                var value = execNode(node.children[0], scope);
                return castValue(value, to);

            case Cast(to):
                return execNode(node.children[0], scope); // ignored

            case BinaryOperation(op, resType):
                var left = execNode(node.children[0], scope);
                var right = execNode(node.children[1], scope);
                var result: Dynamic = switch(op) {
                    case "+": left.value + right.value;
                    case "-": left.value - right.value;
                    case "*": left.value * right.value;
                    case "/": left.value / right.value;
                    case "%": left.value % right.value;
                    case "==": left.value == right.value;
                    case "!=": left.value != right.value;
                    case "<": left.value < right.value;
                    case "<=": left.value <= right.value;
                    case ">": left.value > right.value;
                    case ">=": left.value >= right.value;
                    case "&&": left.value && right.value;
                    case "||": left.value || right.value;
                    default: 0;
                }

                return { type: resType, value: resType.eq(AnalyzerType.TInt) ? Std.int(result) : result };

            case FunctionDecl(desc):
                var decl: EvalFunction = {
                    desc: desc,
                    scope: scope.copy(),
                    body: node.children
                };

                scope.functions.push(decl);
                return { type: AnalyzerType.TVoid, value: decl };

            case VarDecl(decl):
                var value = execNode(node.children[0], scope);
                var v: EvalVariable = {
                    name: decl.name,
                    value: value
                };

                scope.variables.push(v);
                return value;

            case IdentifierNode(name, resType):
                var v = scope.findVariable(name);
                if (v == null) {
                    throw "Unknown variable: " + name;
                }

                return v.value;

            case FunctionCall(name, remappedName):
                var func = scope.findFunction(name);
                if (func == null) {
                    throw 'Unknown function: ' + name;
                }

                var localScope = func.scope.copy();
                for (i in 0...func.desc.parameters.length) {
                    var param = func.desc.parameters[i];
                    var argNode = node.children[i];
                    localScope.variables.push({
                        name: param.name,
                        value: execNode(argNode, scope)
                    });
                }

                execBody(func.body, localScope);

                return localScope.returnValue;

            case Return:
                return scope.returnValue = execNode(node.children[0], scope);

            case CCode(value):
                return { type: AnalyzerType.TAny, value: 0 };

            default:
                return { type: AnalyzerType.TVoid, value: 0 };
        }
    }

}