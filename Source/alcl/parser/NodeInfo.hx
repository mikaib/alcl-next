package alcl.parser;

import alcl.tokenizer.TokenInfo;

@:structInit
class NodeInfo {
    public var min: TokenInfo;
    public var max: TokenInfo;

    public function copy(): NodeInfo {
        return {
            min: this.min,
            max: this.max
        };
    }

    @:to
    public function toString(): String {
        return "NodeInfo(" + min + ", " + max + ")";
    }
}
