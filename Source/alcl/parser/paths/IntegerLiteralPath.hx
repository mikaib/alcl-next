package alcl.parser.paths;

import alcl.parser.ParserPath;
import alcl.tokenizer.TokenKind;

class IntegerLiteralPath extends ParserPath {

    override public function onRun(): Void {
        var token = expectKind(IntegerLiteral);
        var info = getCurrentInfo();

        submitNode({
            kind: IntegerLiteralNode(token.value),
            info: info
        });
    }

}
