package alcl.parser.paths;

import alcl.tokenizer.TokenKind;
import alcl.parser.ParserPath;
import alcl.analyzer.AnalyzerReifyMode;

class ReifyPath extends ParserPath {

    override public function onRun(): Void {
        var kindStr = expectKind(Identifier);
        if (kindStr.value.length != 1) {
            fail();
            return;
        }

        expectKind(Dollar);

        var expr = expectBlock(LeftBrace, RightBrace);
        var exprAst = parse(expr, true);
        var mode: AnalyzerReifyMode = switch (kindStr.value) {
            case "v": AnalyzerReifyMode.ReifyValue;
            case "e": AnalyzerReifyMode.ReifyExpression;
            default:
                fail();
                return;
        }

        if (!success) {
            return;
        }

        var posInfos = getCurrentInfo();
        submitNode({
            kind: NodeKind.Reify(mode),
            info: posInfos,
            children: exprAst
        });
    }

}
