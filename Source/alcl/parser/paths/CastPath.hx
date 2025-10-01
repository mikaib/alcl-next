package alcl.parser.paths;

import alcl.parser.ParserPath;
import alcl.tokenizer.TokenKind;
import alcl.analyzer.AnalyzerType;

class CastPath extends ParserPath {

    override public function onRun(): Void {
        expectKind(LeftParen);
        var castType = expectType();
        expectKind(RightParen);

        if (!success) {
            return;
        }

        var castNode = expectNextNode();
        var info = getCurrentInfo();

        submitNode({
            kind: Cast(castType),
            info: info,
            children: [
                castNode
            ]
        });
    }

}
