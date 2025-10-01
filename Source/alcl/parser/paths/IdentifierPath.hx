package alcl.parser.paths;

import alcl.parser.ParserPath;
import alcl.tokenizer.TokenKind;
import alcl.analyzer.AnalyzerType;

class IdentifierPath extends ParserPath {

    override public function onRun(): Void {
        var token = expectKind(Identifier);
        var info = getCurrentInfo();

        if (!isInline && !BinaryOperationPath.isOperator(peek().kind)) {
            fail();
            return;
        }

        submitNode({
            kind: IdentifierNode(token.value, AnalyzerType.TDependant),
            info: info
        });
    }

}
