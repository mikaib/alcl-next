package alcl.parser.paths;

import alcl.analyzer.AnalyzerType;
import alcl.parser.ParserPath;
import alcl.tokenizer.TokenKind;
import alcl.Error;

class ReturnPath extends ParserPath {

    override public function onRun(): Void {
        expectKindAndValue(Identifier, "return");

        var before = success;
        var tokens = expectBlock(None, Semicolon);

        if (!success) {
            if (before) parser.getContext().emitError(parser.getModule(), ParserExpectedToken(Semicolon, getCurrentInfo()));
            return;
        }

        var parsed = parse(tokens, true);

        if (parsed.length != 1) {
            fail();
            return;
        }

        var node: Node = parsed[0];
        if (node == null || node.kind == null) {
            fail();
            return;
        }

        var info = getCurrentInfo();
        submitNode({
            kind: Return(AnalyzerType.TUnknown),
            info: info,
            children: [node]
        });
    }

}
