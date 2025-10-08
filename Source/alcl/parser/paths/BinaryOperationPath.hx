package alcl.parser.paths;

import alcl.parser.ParserPath;
import alcl.tokenizer.TokenKind;
import alcl.analyzer.AnalyzerType;

class BinaryOperationPath extends ParserPath {

    override public function onRun(): Void {
        var operatorToken = advance();
        if (!isOperator(operatorToken.kind)) {
            fail();
            return;
        }

        var left = currentAst.pop();
        if (left == null) {
            fail();
            return;
        }

        var precedence = getPrecedence(operatorToken.kind);
        var rightTokens = [];
        var subExprDepth = 0;

        while (hasMoreTokens()) {
            var currentToken = peek();

            if (currentToken.kind == LeftParen) {
                subExprDepth++;
            }

            if (isOperator(currentToken.kind) && getPrecedence(currentToken.kind) < (precedence + 1) && subExprDepth == 0 && rightTokens.length > 0) {
                break;
            }

            if (currentToken.kind == RightParen) {
                subExprDepth--;
            }

            rightTokens.push(advance());
        }

        if (rightTokens.length == 0) {
            fail();
            return;
        }

        var rightAST = parse(rightTokens, true);
        if (rightAST.length == 0) {
            fail();
            return;
        }

        if (rightAST.length > 1) {
            fail();
            return;
        }

        var info = getCurrentInfo();

        submitNode({
            kind: BinaryOperation(operatorToken.value, AnalyzerType.TDependant),
            info: info,
            children: [
                left,
                rightAST[0]
            ]
        });
    }

    public static function isOperator(kind: TokenKind): Bool {
        return switch (kind) {
            case Plus, Minus, Star, Slash, Percent, Equal, NotEqual, Greater, GreaterEqual, Less, LessEqual, And, Or, Not, Arrow, Question:
                true;
            default:
                false;
        };
    }

    public static function getPrecedence(op: TokenKind): Int {
        switch (op) {
            case Arrow:
                return 0;
            case Or:
                return 1;
            case And:
                return 2;
            case Question:
                return 3;
            case Equal, NotEqual:
                return 4;
            case Less, LessEqual, Greater, GreaterEqual:
                return 5;
            case Plus, Minus:
                return 6;
            case Star, Slash, Percent:
                return 7;
            case Not:
                return 8;
            default:
                throw "Unknown operation: " + op;
        }
    }

}
