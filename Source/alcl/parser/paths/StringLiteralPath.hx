package alcl.parser.paths;

import alcl.tokenizer.TokenKind;
import alcl.parser.ParserPath;

class StringLiteralPath extends ParserPath {

    override public function onRun(): Void {
        var token = expectKind(StringLiteral);
        var info = getCurrentInfo();

        submitNode({
            kind: StringLiteralNode(token.value),
            info: info
        });
    }

}
