package alcl;

import alcl.Warning;

class WarningUtil {

    public static function nodeInfoToString(info: alcl.parser.NodeInfo): String {
        return info != null ? info.min.toString() : "internal";
    }

    public static function tokenInfoToString(info: alcl.tokenizer.TokenInfo): String {
        return info.line + ":" + Std.int(info.column - info.length + 1);
    }

    public static function warningToString(error: Warning): { message: String, pos: Null<String> } {
        switch (error) {
            case AnalyzerNarrowingConversion(from, to, c):
                return { message: 'Narrowing conversion: converting ${from.toHumanReadableString()} to ${to.toHumanReadableString()}', pos: nodeInfoToString(c?.have?.node?.info) };
        }

        throw 'Unknown warning type';
    }

}
