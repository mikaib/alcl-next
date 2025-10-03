package alcl.macro;

import alcl.parser.Node;
import alcl.parser.AST;
import alcl.parser.NodeKind;
import alcl.analyzer.AnalyzerType;

class MacroPass {

    public static function processNode(node: Node, module: Module): Void {
        switch (node.kind) {
            case MacroFunctionCall(name, remappedName,  returnType):
                MacroPass.processMacroCall(node, module, name);
            case FunctionDecl(desc):
                if (desc.metas.filter(v -> v.kind == Macro).length <= 0) {
                    processBody(node.children, module);
                }

            default:
                processBody(node.children, module);
        }
    }

    public static function processMacroCall(node: Node, module: Module, name: String): Void {
        var moduleEvaluator = module.getEvaluatorSafe();
        var macroResult = moduleEvaluator.execNode(node, moduleEvaluator.getExports());

        if (macroResult.type.eq(AnalyzerType.TExpr)) {
            processNode(macroResult.value, module);
        }

        node.kind = moduleEvaluator.toLiteral(macroResult);
        node.children = [];
    }

    public static function processBody(body: AST, module: Module): Void {
        for (node in body) {
            processNode(node, module);
        }
    }

}
