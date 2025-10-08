package alcl.parser.paths;

import alcl.tokenizer.TokenKind;
import alcl.parser.ParserPath;

class UntypedPath extends ParserPath {

    override public function onRun(): Void {
        expectKindAndValue(Identifier, "untyped");
        if (!success) {
            return;
        }

        var typelessNode = expectNextNode();
        var info = getCurrentInfo();

        submitNode({
            kind: Untyped,
            info: info,
            children: [typelessNode]
        });
    }

}
