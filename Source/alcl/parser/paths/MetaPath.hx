package alcl.parser.paths;

import alcl.tokenizer.TokenKind;
import alcl.parser.ParserPath;

class MetaPath extends ParserPath {

    override public function onRun(): Void {
        expectKind(At);

        var type = expectKind(Identifier);
        var argTokens = expectBlock(LeftParen, RightParen);
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

        if (!success) {
            return;
        }

        var info = getCurrentInfo();
        submitNode({
            kind: Meta(type.value),
            info: info,
            children: args
        });
    }

}
