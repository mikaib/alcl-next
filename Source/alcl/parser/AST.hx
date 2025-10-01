package alcl.parser;

@:forward
abstract AST(Array<Node>) from Array<Node> to Array<Node> {
    public function stringify(depth: Int = 0): String {
        var result = "";
        for (node in this) {
            result += node.stringify(depth);
        }
        return result;
    }

    public function copy(): AST {
        var newAst: AST = [];
        for (node in this) {
            newAst.push(node.copy());
        }
        return newAst;
    }

    @:to
    public function toString(): String {
        return stringify();
    }
}
