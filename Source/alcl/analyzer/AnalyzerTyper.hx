package alcl.analyzer;

import alcl.parser.Node;
import alcl.parser.AST;
import alcl.parser.NodeKind;

class AnalyzerTyper {

    public var module: Module;
    public var context: Context;
    public var solver: AnalyzerSolver;
    public var globalScope: AnalyzerScope;

    public function new(module: Module) {
        this.module = module;
        this.context = module.parser.getContext();
        this.solver = new AnalyzerSolver(this);
    }

    public function run(ast: AST): AST {
        var localScope: AnalyzerScope = {};
        var localAst = module.parser.getAST().copy();

        for (m in module.imports) {
            localScope.functions = localScope.functions.concat(m.functions);
        }

        analyseAst(localAst, localScope);
        solver.solve();

        validateAst(localAst);
        globalScope = localScope;

        return localAst;
    }

    public function validateAst(ast: AST): Void {
        for (node in ast) {
            validateNode(node);
        }
    }

    public function analyseAst(ast: AST, scope: AnalyzerScope): Void {
        var deferred: Array<Void->Void> = [];

        for (node in ast) {
            analyzeNode(node, scope, deferred);
        }

        for (def in deferred) {
            def();
        }
    }

    public function getType(node: Node, scope: AnalyzerScope): AnalyzerType {
        switch (node.kind) {
            case CCode(code):
                return AnalyzerType.TAny;

            case IntegerLiteralNode(value):
                return AnalyzerType.TInt;

            case FloatLiteralNode(value):
                return AnalyzerType.TDouble;

            case StringLiteralNode(value):
                return AnalyzerType.TString;

            case BooleanLiteralNode(value):
                return AnalyzerType.TBool;

            case Untyped:
                return AnalyzerType.TUnknown;

            case VarDecl(desc):
                return desc.type;

            case BinaryOperation(op, resType):
                return resType;

            case MacroFunctionCall(name, remappedName,  returnType):
               return returnType;

            case FunctionCall(name, remappedName, returnType):
                return returnType;

            case FromVariant(type):
                return type.parameters[0];

            case ToVariant(type):
                return type;

            case CCast(type):
                return type;

            case Cast(type):
                return type;

            case TernaryNode(resType):
                return resType;

            case IdentifierNode(name, resType):
                return resType;

            case Reify(mode):
                return getType(node.children[0], scope);

            case Forward(fwNode):
                return getType(fwNode, scope);

            default:
                trace('Unhandled node kind - getType: ' + node);
        }

        return AnalyzerType.TUnknown;
    }

    public function validateNode(node: Node): Void {
        switch (node.kind) {
            case Cast(to):
                validateAst(node.children);

                var from = getType(node.children[0], node.validationScope);
                if (from.eq(to)) {
                    return;
                }

                var path = solver.findCast(from, to);
                if (path == null || path.length == 0) {
                    context.emitError(module, AnalyzerInvalidCast(from, to, node.info));
                    return;
                }

                solver.tryCast({ // we can savely do this as the type has been assumed as "to" during analysis.
                    have: AnalyzerPair.fromNode(node.children[0], from),
                    want: AnalyzerPair.fromType(to),
                    explicit: true
                });

            default:
                validateAst(node.children);
        }
    }

    public function analyzeNode(node: Node, scope: AnalyzerScope, deferred: Array<Void->Void>): Void {
        node.validationScope = scope;

        switch (node.kind) {
            case FunctionDecl(desc):
                desc.remappedName = module.getSafeName(desc.name);

                module.functions.push(desc);
                scope.functions.push(desc);

                deferred.push(() -> {
                    var localScope = scope.copy().setCurrentFunction(desc);
                    for (p in desc.parameters) {
                        localScope.variables.push({
                            name: p.name,
                            module: module,
                            type: p.type,
                            info: node.info
                        });
                    }

                    analyseAst(node.children, localScope);
                });

            case FunctionCall(name, remappedName, returnType):
                analyseAst(node.children, scope);

                var f = scope.findFunction(name);
                if (f == null) {
                    context.emitError(module, AnalyzerUnknownFunction(name, node.info));
                }

                for (idx in 0...f.parameters.length) {
                    var param = f.parameters[idx];
                    var child = node.children[idx];

                    solver.nodeMustMatchType(param.type, child, scope);
                }

                solver.nodeMustMatchType(f.returnType, node, scope);

                if (f.metas.filter(m -> m.kind == Macro).length > 0) {
                    node.kind = NodeKind.MacroFunctionCall(name, f.remappedName, returnType);
                    return;
                }

                node.kind = NodeKind.FunctionCall(name, f.remappedName, returnType);

            case Return:
                if (scope.currentFunction == null) {
                    context.emitError(module, AnalyzerReturnOutsideFunction(node.info));
                    return;
                }

                analyseAst(node.children, scope);
                solver.nodeMustMatchType(scope.currentFunction.returnType, node.children[0], scope);

            case BinaryOperation(op, res):
                analyseAst(node.children, scope);

                var eq = solver.nodeMustMatchNode(node.children[0], node.children[1], scope);
                solver.nodeMustMatchType(eq, node, scope);

            default:
                analyseAst(node.children, scope);
        }
    }

}
