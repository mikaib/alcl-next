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
        for (node in ast) {
            analyzeNode(node, scope);
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

            case VarDecl(desc):
                return desc.type;

            case BinaryOperation(op, resType):
                return resType;

            case FunctionCall(name, remappedName):
                var f = scope.findFunction(name);
                if (f == null) {
                    context.emitError(module, AnalyzerUnknownFunction(name, node.info));
                }

                var tmp = AnalyzerType.TUnknown;
                return solver.nodeMustMatchTypeVerbose(f.returnType, tmp, node, scope);

            case CCast(type):
                return type.copy();

            case Cast(type):
                return type.copy();

            case IdentifierNode(name, resType):
                return resType;

            default:
                trace('Unhandled node kind - getType: ' + node);
        }

        return AnalyzerType.TAny;
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

    public function analyzeNode(node: Node, scope: AnalyzerScope): Void {
        node.validationScope = scope;

        switch (node.kind) {
            case FunctionDecl(desc):
                desc.remappedName = module.getSafeName(desc.name);

                module.functions.push(desc);
                scope.functions.push(desc);

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

            case VarDecl(desc):
                scope.variables.push(desc);
                analyseAst(node.children, scope);

                solver.nodeMustMatchType(desc.type, node.children[0], scope);

            case FunctionCall(name, remappedName):
                var f = scope.findFunction(name);
                if (f == null) {
                    context.emitError(module, AnalyzerUnknownFunction(name, node.info));
                }

                analyseAst(node.children, scope);

                for (i in 0...f.parameters.length) {
                    var declParam = f.parameters[i];
                    var callParam = node.children[i];

                    if (callParam == null || declParam == null) {
                        throw "too few parameters in function call";
                    }

                    var tmp = AnalyzerType.TUnknown;
                    solver.nodeMustMatchType(tmp, callParam, scope);
                    solver.nodeMustMatchTypeVerbose(declParam.type, tmp, callParam, scope);
                }

                node.kind = NodeKind.FunctionCall(name, f.remappedName);

            case BinaryOperation(op, resType):
                analyseAst(node.children, scope);
                solver.nodeMustMatchNodeRes(node.children[0], node.children[1], resType, scope);

            case IdentifierNode(name, resType):
                var v = scope.findVariable(name);
                if (v == null) {
                    context.emitError(module, AnalyzerUnknownVariable(name, node.info));
                }

                var tmp = AnalyzerType.TUnknown;
                solver.nodeMustMatchTypeVerboseRes(tmp, v.type, resType, node, scope);

            case Return:
                if (node.children.length == 0) {
                    return;
                }

                if (scope.currentFunction == null) {
                    context.emitError(module, AnalyzerReturnOutsideFunction(node.info));
                    return;
                }

                analyseAst(node.children, scope);

                var tmp = AnalyzerType.TUnknown;
                solver.nodeMustMatchType(tmp, node.children[0], scope);
                solver.nodeMustMatchTypeVerbose(scope.currentFunction.returnType, tmp, node.children[0], scope);

            default:
                analyseAst(node.children, scope);
        }
    }

}
