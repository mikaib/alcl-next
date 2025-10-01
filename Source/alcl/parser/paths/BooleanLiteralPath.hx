package alcl.parser.paths;

import alcl.parser.ParserPath;
import alcl.tokenizer.TokenKind;

class BooleanLiteralPath extends ParserPath {

    override public function onRun(): Void {
        var token = expectKind(BooleanLiteral);
        var info = getCurrentInfo();

        submitNode({
            kind: BooleanLiteralNode(token.value),
            info: info
        });
    }

}
