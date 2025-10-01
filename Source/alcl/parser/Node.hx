package alcl.parser;
import alcl.analyzer.AnalyzerScope;

@:structInit
class Node {
    public var kind: NodeKind;
    public var info: NodeInfo;
    public var children: Array<Node> = [];
    public var validationScope: AnalyzerScope = null;

    public function stringify(depth: Int = 0): String {
        var indent = StringTools.lpad("", " ", depth * 2);
        var result = indent + Std.string(kind) + " (" + info.min.line + ":" + info.min.column + " - " + info.max.line + ":" + info.max.column + ")\n";

        for (child in children) {
            result += child.stringify(depth + 1);
        }

        return result;
    }

    public function wrap(node: Node): Void{
        var newNode: Node = {
            kind: this.kind,
            info: this.info.copy(),
            children: this.children.copy(),
            validationScope: this.validationScope
        };

        kind = node.kind;
        info = node.info.copy();
        children = node.children.copy();
        validationScope = node.validationScope;

        children.push(newNode);
    }

    public function copy(): Node {
        var newNode: Node = {
            kind: this.kind,
            info: this.info.copy(),
            validationScope: this.validationScope,
            children: []
        };

        for (child in this.children) {
            newNode.children.push(child.copy());
        }

        return newNode;
    }

    @:to
    public function toString(): String {
        return stringify();
    }

}
