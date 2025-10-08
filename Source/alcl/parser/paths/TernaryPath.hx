package alcl.parser.paths;

import alcl.tokenizer.TokenKind;
import alcl.parser.ParserPath;
import alcl.analyzer.AnalyzerType;

class TernaryPath extends ParserPath {

    override public function onRun(): Void {
        expectKind(Question);
        if (!success) return;

        var condNode = currentAst.pop();
        if (condNode == null) {
            fail();
            return;
        }

        var trueTokens = [];
        var depth = 0;
        while (hasMoreTokens()) {
            var t = peek();
            if (t == null) break;
            if (t.kind == TokenKind.LeftParen) depth++;
            if (t.kind == TokenKind.RightParen) depth--;
            if (t.kind == TokenKind.Colon && depth == 0) break;
            trueTokens.push(advance());
        }

        if (expectKind(TokenKind.Colon) == null) {
            fail();
            return;
        }

        var falseTokens = [];
        while (hasMoreTokens()) {
            falseTokens.push(advance());
        }

        var trueAst = parse(trueTokens, true);
        var falseAst = parse(falseTokens, true);

        if (trueAst.length == 0 || falseAst.length == 0) {
            fail();
            return;
        }

        var info = getCurrentInfo();

        submitNode({
            kind: TernaryNode(AnalyzerType.TDependant),
            info: info,
            children: [
                condNode,
                trueAst[0],
                falseAst[0]
            ]
        });
    }

}
