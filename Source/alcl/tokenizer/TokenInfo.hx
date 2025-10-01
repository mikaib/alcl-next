package alcl.tokenizer;

@:structInit
class TokenInfo {
    public var line: Int = 0;
    public var column: Int = 0;
    public var position: Int = 0;
    public var length: Int = 1;

    @:to(String)
    public function toString(): String {
        return line + ":" + Std.int(column - length + 1);
    }

}