package alcl.parser.paths;

import alcl.tokenizer.TokenKind;
import alcl.parser.ParserPath;

class SemicolonPath extends ParserPath {

    override public function onRun(): Void {
        expectKind(Semicolon);
    }

}
