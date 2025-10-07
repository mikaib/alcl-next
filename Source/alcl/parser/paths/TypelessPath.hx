package alcl.parser.paths;

import alcl.tokenizer.TokenKind;
import alcl.parser.ParserPath;

class TypelessPath extends ParserPath {

    override public function onRun(): Void {
        expectKindAndValue(Identifier, "typeless");
        if (!success) {
            return;
        }

        var typelessNode = expectNextNode();
        var info = getCurrentInfo();

        submitNode({
            kind: Typeless,
            info: info,
            children: [typelessNode]
        });
    }

}
