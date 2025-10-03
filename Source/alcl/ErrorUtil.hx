package alcl;

import alcl.Error;

class ErrorUtil {

    public static function nodeInfoToString(info: alcl.parser.NodeInfo): String {
        return info != null ? info.min.toString() : "internal";
    }

    public static function tokenInfoToString(info: alcl.tokenizer.TokenInfo): String {
        return info.line + ":" + Std.int(info.column - info.length + 1);
    }

    public static function errorToString(error: Error): { message: String, pos: Null<String> } {
        switch (error) {
            case ModuleNotFound(module):
                return { message: 'Module not found: $module', pos: null };
            case ParserExpectedToken(token, info):
                return { message: 'Expected token: $token', pos: nodeInfoToString(info) };
            case ParserUnexpectedToken(token):
                return { message: 'Unexpected token: ${token.kind}${token.value != null ? '(${token.value})' : ""}', pos: token.info.toString() };
            case ParserUnmatchedParenthesis(info):
                return { message: 'Unmatched parenthesis', pos: tokenInfoToString(info) };
            case ParserUnknownMeta(meta, info):
                return { message: 'Unknown meta of type: $meta', pos: nodeInfoToString(info) };
            case ParserInvalidMetaArgument(arg, meta, info):
                return { message: 'Invalid argument for meta $meta: $arg', pos: nodeInfoToString(info) };
            case TokenizerPreprocessorError(message, info):
                return { message: 'Preprocessor error: $message', pos: tokenInfoToString(info) };
            case TokenizerUnterminatedString(info):
                return { message: 'Unterminated string', pos: tokenInfoToString(info) };
            case TokenizerInvalidCharacter(char, info):
                return { message: 'Invalid character: ${String.fromCharCode(char)}', pos: tokenInfoToString(info) };
            case AnalyzerUnknownFunction(name, info):
                return { message: 'Unknown function: $name', pos: nodeInfoToString(info) };
            case AnalyzerUnknownVariable(name, info):
                return { message: 'Unknown variable: $name', pos: nodeInfoToString(info) };
            case AnalyzerTypeMismatch(c):
                return { message: 'Type mismatch: expected ${c.want.type.toHumanReadableString()} but got ${c.have.type.toHumanReadableString()}', pos: nodeInfoToString(c?.have?.node?.info) };
            case AnalyzerUnknownType(type, info):
                return { message: 'Unknown type: $type', pos: nodeInfoToString(info) };
            case AnalyzerReturnOutsideFunction(info):
                return { message: 'Return statement outside of function', pos: nodeInfoToString(info) };
            case AnalyzerInvalidConversionFunction(name, info):
                return { message: 'Invalid conversion function: $name, it must have one parameter!', pos: nodeInfoToString(info) };
            case AnalyzerInvalidCast(from, to, info):
                return { message: 'Invalid cast: cannot cast from ${from.toHumanReadableString()} to ${to.toHumanReadableString()}', pos: nodeInfoToString(info) };
            case AnalyzerReifyOutsideMacro(info):
                return { message: 'Reification outside of macro', pos: nodeInfoToString(info) };
        }

        throw 'Unknown error type';
    }

}
