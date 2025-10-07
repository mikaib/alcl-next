package alcl.parser.paths;

import alcl.parser.ParserPath;
import alcl.tokenizer.TokenKind;
import alcl.Error;
import alcl.analyzer.AnalyzerType;

class VariableDeclPath extends ParserPath {

    override public function onRun(): Void {
        expectKindAndValue(Identifier, "var");
        var varName = expectKind(Identifier);
        var varType = AnalyzerType.TUnknown;

        if (ifKind(Colon)) {
            varType = expectType();
        }

        expectKind(Assign);

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
        var module = parser.getModule();

        submitNode({
            kind: VarDecl({
                name: varName.value,
                module: module,
                type: varType,
                info: info
            }),
            info: info,
            children: [node]
        });
    }

}
