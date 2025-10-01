package alcl.parser;

import alcl.tokenizer.Token;

@:structInit
class ParserExecDesc {
    public var parser: Parser;
    public var tokens: Array<Token>;
    public var tokenIndex: Int;
    public var ast: AST;
    public var isInline: Bool;
}
