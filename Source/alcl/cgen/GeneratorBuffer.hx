package alcl.cgen;

abstract GeneratorBuffer({ v: String }) {

    public function new(v: String = "") {
        this = { v: v };
    }

    public static function makeIndented(v: String, indent: Int): String {
        var pad = "";
        for (i in 0...indent) pad += "    ";
        return pad + v;
    }

    public inline function print(v: String, indent: Int = 0): GeneratorBuffer {
        this.v += makeIndented(v, indent);
        return abstract;
    }

    public inline function println(v: String = "", indent: Int = 0): GeneratorBuffer {
        this.v += makeIndented(v + "\n", indent);
        return abstract;
    }

    @:to
    public function toString(): String {
        return this.v;
    }

}
