package alcl.tokenizer;

@:structInit
class Token {
    public var kind: TokenKind;
    public var info: TokenInfo;
    public var value: String = "";

    @:to
    public function toString(): String {
        return "Token(" + kind + ", '" + value + "', " + info + ")";
    }

}
