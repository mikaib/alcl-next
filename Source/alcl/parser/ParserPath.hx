package alcl.parser;

import alcl.tokenizer.Token;
import alcl.tokenizer.TokenKind;
import alcl.Error;
import haxe.EnumTools.EnumValueTools;
import alcl.analyzer.AnalyzerType;

class ParserPath {

    public var parser: Parser;
    public var tokens: Array<Token>;
    public var currentPos: Int;
    public var beginPos: Int;
    public var success: Bool;
    public var submitted: Bool;
    public var result: Node;
    public var isInline: Bool;
    public var currentAst: AST;

    public function onRun(): Void {}

    public function new() {
        this.tokens = [];
        this.beginPos = 0;
        this.currentPos = 0;
        this.success = false;
        this.submitted = false;
        this.result = null;
    }

    public function expectBlock(startDelim: TokenKind, endDelim: TokenKind, depth: Int = 0): Array<Token> {
        if (startDelim != None) {
            if (expectKind(startDelim) == null) {
                fail();
                return [];
            }
        }

        var localTokens = [];
        while (currentPos < tokens.length) {
            var token = peek();

            if (token == null) {
                fail();
                return [];
            }

            if (EnumValueTools.equals(token.kind, endDelim)) {
                if (depth <= 0) {
                    if (endDelim == Semicolon) localTokens.push(advance());
                    else advance();

                    return localTokens;
                } else {
                    depth--;
                }
            } else if (EnumValueTools.equals(token.kind, startDelim)) {
                depth++;
            }

            localTokens.push(advance());
        }

        fail();
        return [];
    }

    public function expectKind(kind: TokenKind): Token {
        var token = peek();

        if (token == null) {
            return fail();
        }

        if (!EnumValueTools.equals(token.kind, kind)) {
            return fail();
        }

        return advance();
    }

    public function ifKind(kind: TokenKind, advanceBy: Int = 1): Bool {
        var token = peek();

        if (token == null) {
            return false;
        }

        if (!EnumValueTools.equals(token.kind, kind)) {
            return false;
        }

        advance(advanceBy);
        return true;
    }

    public function requireKind(kind: TokenKind): Token {
        // this one is a bit special as it requires all previous tokens to be OK
        // this function will assume the current path will not fail and will throw a compiler error if the token isn't correct.
        // this can be used for something like semicolons.
        var token = peek();

        if (token == null) {
            if (success) parser.getContext().emitError(parser.getModule(), ParserExpectedToken(kind, getCurrentInfo()));
            return fail();
        }

        if (!EnumValueTools.equals(token.kind, kind)) {
            if (success) parser.getContext().emitError(parser.getModule(), ParserExpectedToken(kind, getCurrentInfo()));
            return fail();
        }

        return advance();
    }

    public function expectValue(value: String): Token {
        var token = peek();

        if (token == null) {
            return fail();
        }

        if (token.value != value) {
            return fail();
        }

        return advance();
    }

    public function ifValue(value: String, advanceBy: Int = 1): Bool {
        var token = peek();

        if (token == null) {
            return false;
        }

        if (token.value != value) {
            return false;
        }

        advance(advanceBy);
        return true;
    }

    public function expectKindAndValue(kind: TokenKind, value: String): Token {
        var token = peek();

        if (token == null) {
            return fail();
        }

        if (!EnumValueTools.equals(token.kind, kind)) {
            return fail();
        }

        if (token.value != value) {
            return fail();
        }

        return advance();
    }

    public function ifKindAndValue(kind: TokenKind, value: String, advanceBy: Int = 1): Bool {
        var token = peek();

        if (token == null) {
            return false;
        }

        if (!EnumValueTools.equals(token.kind, kind)) {
            return false;
        }

        if (token.value != value) {
            return false;
        }

        advance(advanceBy);
        return true;
    }

    public function expectType(advanceBy: Int = 0): AnalyzerType {
        var typeStr = "";
        var depth = 0;

        while (currentPos < tokens.length) {
            var token = peek();
            if (token == null) break;

            switch (token.kind) {
                case Comma:
                    if (depth > 0) {
                        typeStr += token.value;
                        advance();
                    } else {
                        break;
                    }
                case Less:
                    depth++;
                    typeStr += token.value;
                    advance();
                case Greater:
                    if (depth > 0) {
                        depth--;
                        typeStr += token.value;
                        advance();
                    } else {
                        break;
                    }
                case Identifier:
                    typeStr += token.value;
                    advance();
                default:
                    break;
            }
        }

        if (typeStr == "" || depth != 0) {
            fail();
            return null;
        }

        return AnalyzerType.ofString(typeStr);
    }

    public function getCurrentInfo(): NodeInfo {
        return {
            min: tokens[beginPos].info,
            max: tokens[currentPos >= tokens.length ? tokens.length - 1 : currentPos].info
        }
    }

    public function peek(by: Int = 0): Token {
        if (this.currentPos + by < this.tokens.length) {
            return this.tokens[this.currentPos + by];
        } else {
            return null;
        }
    }

    public function advance(by: Int = 1): Token {
        this.currentPos += by;
        if (this.currentPos >= this.tokens.length + 1) {
            this.success = false;
        }

        return peek(-1);
    }

    public function fail(): Token {
        this.success = false;
        return peek();
    }

    public function succeed(): Void {
        this.success = true;
    }

    public function submitNode(data: Node): Void {
        this.submitted = true;
        this.result = data;
    }

    public function parse(tokens: Array<Token>, isInline: Bool = false): AST {
        if (tokens == null || tokens.length == 0 || !this.success) {
            return [];
        }

        var parser = new Parser(this.parser.getModule(), this.parser.getContext(), tokens, isInline);
        return parser.getAST();
    }

    public function createPath(tokens: Array<Token>, isInline: Bool = false): ParserPath {
        var path = new ParserPath();
        path.exec({
            parser: parser,
            tokens: tokens,
            tokenIndex: 0,
            ast: currentAst,
            isInline: false
        });

        return path;
    }

    public function expectNextNode(): Node {
        var tokens = this.tokens.slice(this.currentPos, this.tokens.length);

        var parser = new Parser(this.parser.getModule(), this.parser.getContext(), tokens, this.isInline, false);
        var out = parser.execUntilFirst(tokens, 0, this.isInline);
        this.currentPos += out.advance;

        return out.node;
    }

    public function splitTokenList(list: Array<Token>, delimiter: TokenKind = TokenKind.Comma, depthInc: TokenKind = LeftParen, depthDec: TokenKind = RightParen, depth: Int = 0): Array<Array<Token>> {
        var result = [];
        var currentList = [];
        for (token in list) {
            if (EnumValueTools.equals(token.kind, delimiter)) {
                if (depth == 0) {
                    result.push(currentList);
                    currentList = [];
                } else {
                    currentList.push(token);
                }
            } else if (EnumValueTools.equals(token.kind, depthInc)) {
                depth++;
                currentList.push(token);
            } else if (EnumValueTools.equals(token.kind, depthDec)) {
                if (depth > 0) {
                    depth--;
                    currentList.push(token);
                } else {
                    throw ParserUnmatchedParenthesis(token.info);
                }
            } else {
                currentList.push(token);
            }
        }

        if (currentList.length > 0) {
            result.push(currentList);
        }

        return result;
    }

    public function hasMoreTokens(): Bool {
        return this.currentPos < this.tokens.length;
    }

    public function exec(desc: ParserExecDesc): Void {
        this.parser = desc.parser;
        this.tokens = desc.tokens;
        this.beginPos = desc.tokenIndex;
        this.currentPos = desc.tokenIndex;
        this.currentAst = desc.ast;
        this.success = true;
        this.submitted = false;
        this.result = null;
        this.isInline = desc.isInline;

        onRun();
    }

}
