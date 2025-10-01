package alcl.parser.paths;

import alcl.parser.ParserPath;
import alcl.tokenizer.TokenKind;

class FloatLiteralPath extends ParserPath {

    override public function onRun(): Void {
        var token = expectKind(FloatLiteral);
        var info = getCurrentInfo();

        submitNode({
            kind: FloatLiteralNode(token.value),
            info: info
        });
    }

}
