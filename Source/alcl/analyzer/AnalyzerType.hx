package alcl.analyzer;

class AnalyzerType {

    public static final POINTER_SIZE: Int = 8;
    public static var GTID: Int = 0;

    public var id: Int;
    public var baseType: String;
    public var fallbackType: AnalyzerType;

    public static var TVoid(get, never): AnalyzerType;
    private static function get_TVoid(): AnalyzerType return AnalyzerType.ofString("void");

    public static var TInt(get, never): AnalyzerType;
    private static function get_TInt(): AnalyzerType return AnalyzerType.ofString("i32");

    public static var TFloat(get, never): AnalyzerType;
    private static function get_TFloat(): AnalyzerType return AnalyzerType.ofString("f32");

    public static var TDouble(get, never): AnalyzerType;
    private static function get_TDouble(): AnalyzerType return AnalyzerType.ofString("f64");

    public static var TBool(get, never): AnalyzerType;
    private static function get_TBool(): AnalyzerType return AnalyzerType.ofString("bool");

    public static var TString(get, never): AnalyzerType;
    private static function get_TString(): AnalyzerType return AnalyzerType.ofString("str");

    public static var TCString(get, never): AnalyzerType;
    private static function get_TCString(): AnalyzerType return AnalyzerType.ofString("c_str");

    public static var TAny(get, never): AnalyzerType;
    private static function get_TAny(): AnalyzerType return AnalyzerType.ofString("any");

    public static var TUnknown(get, never): AnalyzerType;
    private static function get_TUnknown(): AnalyzerType return AnalyzerType.ofString("ALCL_Unknown");

    public static var TDependant(get, never): AnalyzerType;
    private static function get_TDependant(): AnalyzerType return AnalyzerType.ofString("ALCL_Dependant");

    public static function ofString(type: String): AnalyzerType {
        return new AnalyzerType(type);
    }

    public static function Fallback(type: AnalyzerType): AnalyzerType {
        var t = TUnknown;
        t.fallbackType = type;

        return t;
    }

    public function new(baseType: String) {
        this.baseType = baseType;
        this.id = GTID++;
    }

    public function isUnknown(): Bool {
        return baseType == "ALCL_Unknown" || baseType == "ALCL_Dependant";
    }

    public function isDependant(): Bool {
        return baseType == "ALCL_Dependant";
    }

    public function eq(other: AnalyzerType): Bool {
        return baseType == other.baseType && !isDependant() && !other.isDependant();
    }

    public function set(other: AnalyzerType): Void {
        this.baseType = other.baseType;
        this.fallbackType = other.fallbackType;
    }

    public function toCTypeString(): String {
        if (isUnknown() && fallbackType != null) {
            return fallbackType.toCTypeString();
        }

        switch (baseType) {
            case "i32":
                return "int";
            case "f32":
                return "float";
            case "f64":
                return "double";
            case "bool":
                return "int";
            case "str":
                return "const char*";
            case "c_str":
                return "const char*";
            case "void":
                return "void";
        }

        return "ALCL_UNRESOLVED_TYPE"; // will fail at compile time
    }

    public function getSize(): Int {
        if (isUnknown() && fallbackType != null) {
            return fallbackType.getSize();
        }

        switch (baseType) {
            case "i32":
                return 4;
            case "f32":
                return 4;
            case "f64":
                return 8;
            case "bool":
                return 1;
            case "str":
                return POINTER_SIZE;
            case "c_str":
                return POINTER_SIZE;
            case "void":
                return 0;
        }

        return POINTER_SIZE;
    }

    public function isNumeric(): Bool {
        if (isUnknown() && fallbackType != null) {
            return fallbackType.isNumeric();
        }

        return baseType == "i32" || baseType == "f32" || baseType == "f64";
    }

    public function copy(): AnalyzerType {
        var t = new AnalyzerType(baseType);
        t.fallbackType = fallbackType;

        return t;
    }

    @:to
    public function toString(): String {
        // return 'T($baseType, #$id)';

        if (isUnknown() && fallbackType != null) {
            return "AnalyzerType(fallback=" + fallbackType.toString() + ")";
        }

        return "AnalyzerType(" + baseType + ")";
    }

    public function toHumanReadableString(): String {
        if (isUnknown() && fallbackType != null) {
            return fallbackType.toHumanReadableString();
        }

        return baseType ?? "Unknown";
    }

}
