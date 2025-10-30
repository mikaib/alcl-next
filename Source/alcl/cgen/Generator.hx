package alcl.cgen;

import alcl.parser.AST;
import alcl.parser.Node;
import alcl.analyzer.AnalyzerParameter;
import alcl.analyzer.AnalyzerType;
import alcl.analyzer.AnalyzerFunction;

class Generator {
    private var ast: AST;
    private var module: Module;

    public function new(ast: AST, module: Module) {
        this.ast = ast;
        this.module = module;
    }

    public function print(): String {
        var buffer = new GeneratorBuffer();
        var headerPath = module.getPathHeader();

        buffer.println('#include "' + headerPath + '"');

        if (module.imports.length != 0) {
            for (imp in module.imports) {
                var impHeaderPath = imp.getPathHeader();
                buffer.println('#include "' + impHeaderPath + '"');
            }
        }

        var includeMap : Map<String, Bool> = [];
        for (func in module.functions) {
            for (meta in func.metas) {
                if (meta.kind == Include) {
                    var includePath = meta.params[0];
                    if (!includeMap.exists(includePath)) {
                        includeMap.set(includePath, true);
                        buffer.println('#include "$includePath"');
                    }
                }
            }
        }

        buffer.println('');
        printAst(ast, buffer, 0);

        return buffer;
    }

    public function printAst(body: AST, buffer: GeneratorBuffer, indentLevel: Int): Void {
        for (node in body) {
            printStatement(node, buffer, indentLevel);
        }
    }

    private function printStatement(node: Node, buffer: GeneratorBuffer, indentLevel: Int): Void {
        switch (node.kind) {
            case Forward(fwNode):
                return printStatement(fwNode, buffer, indentLevel);
            case FunctionDecl(desc):
                printFunctionDecl(node, buffer, indentLevel, desc);
            case VarDecl(desc):
                buffer.println('${desc.type.toCTypeString()} ${desc.name} = ' + printExpression(node.children[0]) + ';', indentLevel);
            case Return(resType):
                buffer.println('return ' + printExpression(node.children[0]) + ';', indentLevel);
            case Meta(type): null;
            default:
                buffer.println(printExpression(node) + ';', indentLevel);
        }
    }

    private function printExpression(node: Node): String {
        switch (node.kind) {
            case Forward(fwNode):
                return printExpression(fwNode);
            case Reify(mode):
                return printExpression(node.children[0]);
            case Untyped:
                return printExpression(node.children[0]);
            case FromVariant(type):
                return printFromVariant(node, type);
            case ToVariant(type):
                return printToVariant(node, type);
            case BinaryOperation(op, resType):
                return printBinaryOperation(node, op);
            case FunctionCall(name, remappedName, returnType):
                return printFunctionCall(node, name, remappedName);
            case CCode(code):
                return code;
            case CCast(type): // raw cast
                return '((' + type.toCTypeString() + ')' + printExpression(node.children[0]) + ')';
            case Cast(type): // alcl cast
                return printExpression(node.children[0]);
            case IdentifierNode(name, resType):
                return name;
            case StringLiteralNode(value):
                return '"' + value + '"';
            case IntegerLiteralNode(value):
                return value;
            case FloatLiteralNode(value):
                return value;
            case BooleanLiteralNode(value):
                return value == "true" ? "1" : "0";
            case TernaryNode(resType):
                var cond = printExpression(node.children[0]);
                var trueExpr = printExpression(node.children[1]);
                var falseExpr = printExpression(node.children[2]);
                return '((' + cond + ') ? (' + trueExpr + ') : (' + falseExpr + '))';
            default:
                return '';
        }
    }

    private function printToVariant(node: Node, type: AnalyzerType): String {
        var expr = printExpression(node.children[0]);

        if (type.isPointer()) {
            return '(&$expr)';
        }

        return expr;
    }

    private function printFromVariant(node: Node, type: AnalyzerType): String {
        var expr = printExpression(node.children[0]);

        if (type.isPointer()) {
            return '(*$expr)';
        }

        return expr;
    }

    private function printFunctionDecl(node: Node, buffer: GeneratorBuffer, indentLevel: Int, desc: AnalyzerFunction): Void {
        if (desc.metas.filter(m -> m.kind == Macro).length > 0) {
            return;
        }

        var params = [];
        for (param in desc.parameters) {
            params.push('${param.type.toCTypeString()} ${param.name}');
        }

        buffer.println('${desc.returnType.isUnknown() ? 'void' : desc.returnType.toCTypeString()} ${desc.remappedName}(' + params.join(", ") + ') {', indentLevel);
        printAst(node.children, buffer, indentLevel + 1);
        buffer.println('}', indentLevel);
        buffer.println('', indentLevel);
    }

    private function printFunctionCall(node: Node, name: String, remappedName: String): String {
        var args = [];
        for (child in node.children) {
            args.push(printExpression(child));
        }
        return remappedName + '(' + args.join(", ") + ')';
    }

    private function printBinaryOperation(node: Node, op: String): String {
        var left = printExpression(node.children[0]);
        var right = printExpression(node.children[1]);
        return '(' + left + ' ' + op + ' ' + right + ')';
    }

}
