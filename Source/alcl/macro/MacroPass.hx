package alcl.macro;

import alcl.parser.Node;
import alcl.parser.AST;
import alcl.parser.NodeKind;

class MacroPass {

    public static function processNode(node: Node, module: Module): Void {
        switch (node.kind) {
            case MacroFunctionCall(name, remappedName,  returnType):
                MacroPass.processMacroCall(node, module, name);
            default:
                processBody(node.children, module);
        }
    }

    public static function processMacroCall(node: Node, module: Module, name: String): Void {
        var moduleEvaluator = module.getEvaluatorSafe();
        var macroResult = moduleEvaluator.execNode(node, moduleEvaluator.getExports());

        node.kind = moduleEvaluator.toLiteral(macroResult);
        node.children = [];
    }

    public static function processBody(body: AST, module: Module): Void {
        for (node in body) {
            processNode(node, module);
        }
    }

}
