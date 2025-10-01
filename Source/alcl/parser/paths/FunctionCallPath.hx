package alcl.parser.paths;

import alcl.tokenizer.TokenKind;
import alcl.parser.ParserPath;

class FunctionCallPath extends ParserPath {

    override public function onRun(): Void {
        var name = expectKind(Identifier);
        var argTokens = expectBlock(LeftParen, RightParen);
        if (!isInline) requireKind(Semicolon);

        var argList = splitTokenList(argTokens, Comma);
        var args: Array<Node> = [];

        for (arg in argList) {
            var p = parse(arg, true);
            if (p.length != 1) {
                fail();
                return;
            };

            var node: Node = p[0];
            if (node == null || node.kind == null) {
                fail();
                return;
            }

            args.push(node);
        }

        var info = getCurrentInfo();
        var node: Node = {
            kind: FunctionCall(name.value, name.value),
            info: info,
            children: args
        };

        if (name.value == "__inject" && args[0].kind.match(NodeKind.StringLiteralNode(_))) {
            switch (args[0].kind) {
                case StringLiteralNode(value):
                    node.kind = NodeKind.CCode(value);
                    node.children = [];
                case _: null;
            }
        }

        submitNode(node);
    }

}
