package alcl.tokenizer;

import alcl.Error;

using StringTools;

class Tokenizer {

    private var source: String;
    private var position: Int;
    private var length: Int;
    private var defines: Map<String, Dynamic>;
    private var context: Context;
    private var module: Module;
    private var conditionStack: Array<{wasActive: Bool, wasSkipping: Bool, conditionResult: Bool, hasElse: Bool}>;

    /**
     * The Tokenizer class is used to tokenize ALCL source code.
     * @param source The source code to tokenize.
     */
    public function new(module: Module, context: Context, source: String, defines: Map<String, Dynamic>) {
        this.source = source
        .replace("\r\n", "\n")
        .replace("\r", "\n");

        this.position = 0;
        this.length = source.length;
        this.defines = defines;
        this.context = context;
        this.module = module;
        this.conditionStack = [];
    }

    /**
     * Evaluates a condition string against the defined preprocessor directives.
     * @param condition The condition string to evaluate.
     * @return True if the condition is met, false otherwise.
     */
    private function evaluateCondition(condition: String): Bool {
        if (condition.indexOf("||") != -1) {
            var parts = condition.split("||");
            for (part in parts) {
                if (evaluateCondition(part.trim())) {
                    return true;
                }
            }
            return false;
        }

        if (condition.indexOf("&&") != -1) {
            var parts = condition.split("&&");
            for (part in parts) {
                if (!evaluateCondition(part.trim())) {
                    return false;
                }
            }
            return true;
        }

        if (condition.startsWith("!")) {
            return !defines.exists(condition.substr(1).trim());
        } else {
            return defines.exists(condition.trim());
        }
    }

    /**
     * Runs the tokenizer and returns a list of tokens.
     */
    public function run(): Array<Token> {
        var tokens: Array<Token> = [];
        var line: Int = 1;
        var column: Int = 0;

        var skipActive: Bool = false;
        var condActive: Bool = false;

        var appendToken = (token: Token) -> {
            if (!skipActive) {
                tokens.push(token);
            }
        };

        while (position < length) {
            var char = source.charAt(position);
            var initialPosition: Int = position;

            switch (char) {
                case '#':
                    position++;
                    column++;
                    var cmd = "";
                    while (position < length && isLetter(source.charCodeAt(position))) {
                        cmd += source.charAt(position);
                        position++;
                        column++;
                    }

                    cmd = cmd.toLowerCase();
                    var args = [];
                    while (position < length && source.charAt(position) != '\n') {
                        if (source.charAt(position) == ' ') {
                            position++;
                            column++;
                        } else {
                            var arg = "";
                            while (position < length && source.charAt(position) != ' ' && source.charAt(position) != '\n') {
                                if (source.charAt(position) == '"' || source.charAt(position) == '\'') {
                                    position++;
                                    column++;
                                    continue;
                                }
                                arg += source.charAt(position);
                                position++;
                                column++;
                            }
                            args.push(arg);
                        }
                    }

                    position++;
                    column = 0;
                    line++;

                    if (cmd == "if") {
                        if (args.length == 0) {
                            context.emitError(module, TokenizerPreprocessorError(
                                "Missing condition for #if directive",
                                {
                                    line: line,
                                    column: column,
                                    length: position - initialPosition,
                                    position: initialPosition
                                }
                            ));
                        } else {
                            var condition = args.join(" ");
                            var result = evaluateCondition(condition);

                            conditionStack.push({
                                wasActive: condActive,
                                wasSkipping: skipActive,
                                conditionResult: result,
                                hasElse: false
                            });

                            condActive = true;
                            skipActive = skipActive || !result;
                        }
                    } else if (cmd == "else" && condActive) {
                        if (conditionStack.length > 0) {
                            var currentState = conditionStack[conditionStack.length - 1];
                            if (currentState.hasElse) {
                                context.emitError(module, TokenizerPreprocessorError(
                                    "Multiple #else directives for single #if",
                                    {
                                        line: line,
                                        column: column,
                                        length: position - initialPosition,
                                        position: initialPosition
                                    }
                                ));
                            } else {
                                currentState.hasElse = true;
                                skipActive = currentState.wasSkipping || currentState.conditionResult;
                            }
                        }
                    } else if (cmd == "end") {
                        if (conditionStack.length > 0) {
                            var state = conditionStack.pop();
                            skipActive = state.wasSkipping;
                            condActive = state.wasActive;
                        } else {
                            context.emitError(module, TokenizerPreprocessorError(
                                "#end without matching #if",
                                {
                                    line: line,
                                    column: column,
                                    length: position - initialPosition,
                                    position: initialPosition
                                }
                            ));
                        }
                    } else {
                        context.emitError(module, TokenizerPreprocessorError(
                            "Unknown or invalid preprocessor command: #" + cmd,
                            {
                                line: line,
                                column: column,
                                length: position - initialPosition,
                                position: initialPosition
                            }
                        ));
                    }

                case '\t':
                    column += 4;
                    position++;

                case '\n':
                    line++;
                    column = 0;
                    position++;

                case ' ':
                    column++;
                    position++;

                case '@':
                    appendToken({ kind: TokenKind.At, value: "@", info: { line: line, column: column, length: 1, position: initialPosition } });
                    position++;
                    column++;

                case '(':
                    appendToken({ kind: TokenKind.LeftParen, value: "(", info: { line: line, column: column, length: 1, position: initialPosition } });
                    position++;
                    column++;

                case ')':
                    appendToken({ kind: TokenKind.RightParen, value: ")", info: { line: line, column: column, length: 1, position: initialPosition } });
                    position++;
                    column++;

                case '[':
                    appendToken({ kind: TokenKind.LeftBracket, value: "[", info: { line: line, column: column, length: 1, position: initialPosition } });
                    position++;
                    column++;

                case ']':
                    appendToken({ kind: TokenKind.RightBracket, value: "]", info: { line: line, column: column, length: 1, position: initialPosition } });
                    position++;
                    column++;

                case "{":
                    appendToken({ kind: TokenKind.LeftBrace, value: "{", info: { line: line, column: column, length: 1, position: initialPosition } });
                    position++;
                    column++;

                case "}":
                    appendToken({ kind: TokenKind.RightBrace, value: "}", info: { line: line, column: column, length: 1, position: initialPosition } });
                    position++;
                    column++;

                case ',':
                    appendToken({ kind: TokenKind.Comma, value: ",", info: { line: line, column: column, length: 1, position: initialPosition } });
                    position++;
                    column++;

                case '-':
                    if (source.charAt(position + 1) == '>') {
                        appendToken({ kind: TokenKind.Arrow, value: "->", info: { line: line, column: column, length: 2, position: initialPosition } });
                        position += 2;
                        column += 2;
                        continue;
                    }

                    appendToken({ kind: TokenKind.Minus, value: "-", info: { line: line, column: column, length: 1, position: initialPosition } });
                    position++;
                    column++;

                    if (source.charAt(position) == "-") {
                        appendToken({ kind: TokenKind.Assign, value: "=", info: { line: line, column: column, length: 2, position: initialPosition } });
                        appendToken({ kind: TokenKind.IntegerLiteral, value: "1", info: { line: line, column: column, length: 1, position: initialPosition } });
                        position++;
                        column++;
                    }
                case '+':
                    appendToken({ kind: TokenKind.Plus, value: "+", info: { line: line, column: column, length: 1, position: initialPosition } });
                    position++;
                    column++;

                    if (source.charAt(position) == "+") {
                        appendToken({ kind: TokenKind.Assign, value: "=", info: { line: line, column: column, length: 2, position: initialPosition } });
                        appendToken({ kind: TokenKind.IntegerLiteral, value: "1", info: { line: line, column: column, length: 1, position: initialPosition } });
                        position++;
                        column++;
                    }

                case ';':
                    appendToken({ kind: TokenKind.Semicolon, value: ";", info: { line: line, column: column, length: 1, position: initialPosition } });
                    position++;
                    column++;

                case '/':
                    if (source.charAt(position + 1) == '/') {
                        while (position < length && source.charAt(position) != '\n') {
                            position++;
                            column++;
                        }
                    } else {
                        appendToken({ kind: TokenKind.Slash, value: "/", info: { line: line, column: column, length: 1, position: initialPosition } });
                        position++;
                        column++;
                    }

                case '*':
                    appendToken({ kind: TokenKind.Star, value: "*", info: { line: line, column: column, length: 1, position: initialPosition } });
                    position++;
                    column++;

                case '%':
                    appendToken({ kind: TokenKind.Percent, value: "%", info: { line: line, column: column, length: 1, position: initialPosition } });
                    position++;
                    column++;

                case '?':
                    appendToken({ kind: TokenKind.Question, value: "?", info: { line: line, column: column, length: 1, position: initialPosition } });
                    position++;
                    column++;

                case '=':
                    if (source.charAt(position + 1) == '=') {
                        appendToken({ kind: TokenKind.Equal, value: "==", info: { line: line, column: column, length: 2, position: initialPosition } });
                        position += 2;
                        column += 2;
                    } else {
                        appendToken({ kind: TokenKind.Assign, value: "=", info: { line: line, column: column, length: 1, position: initialPosition } });
                        position++;
                        column++;
                    }

                case ':':
                    appendToken({ kind: TokenKind.Colon, value: ":", info: { line: line, column: column, length: 1, position: initialPosition } });
                    position++;
                    column++;

                case '&':
                    if (source.charAt(position + 1) == '&') {
                        appendToken({ kind: TokenKind.And, value: "&&", info: { line: line, column: column, length: 2, position: initialPosition } });
                        position += 2;
                        column += 2;
                    } else {
                        appendToken({ kind: TokenKind.And, value: "&", info: { line: line, column: column, length: 1, position: initialPosition } }); // TODO: Handle bitwise AND
                        position++;
                        column++;
                    }

                case '|':
                    if (source.charAt(position + 1) == '|') {
                        appendToken({ kind: TokenKind.Or, value: "||", info: { line: line, column: column, length: 2, position: initialPosition } });
                        position += 2;
                        column += 2;
                    } else {
                        appendToken({ kind: TokenKind.Or, value: "|", info: { line: line, column: column, length: 1, position: initialPosition } }); // TODO: Handle bitwise OR
                        position++;
                        column++;
                    }

                case '<':
                    if (source.charAt(position + 1) == '=') {
                        appendToken({ kind: TokenKind.LessEqual, value: "<=", info: { line: line, column: column, length: 2, position: initialPosition } });
                        position += 2;
                        column += 2;
                    } else {
                        appendToken({ kind: TokenKind.Less, value: "<", info: { line: line, column: column, length: 1, position: initialPosition } }); // TODO: Handle bitwise left shift
                        position++;
                        column++;
                    }

                case '>':
                    if (source.charAt(position + 1) == '=') {
                        appendToken({ kind: TokenKind.GreaterEqual, value: ">=", info: { line: line, column: column, length: 2, position: initialPosition } });
                        position += 2;
                        column += 2;
                    } else {
                        appendToken({ kind: TokenKind.Greater, value: ">", info: { line: line, column: column, length: 1, position: initialPosition } }); // TODO: Handle bitwise right shift
                        position++;
                        column++;
                    }

                case '!':
                    if (source.charAt(position + 1) == '=') {
                        appendToken({ kind: TokenKind.NotEqual, value: "!=", info: { line: line, column: column, length: 2, position: initialPosition } });
                        position += 2;
                        column += 2;
                    } else {
                        appendToken({ kind: TokenKind.Not, value: "!", info: { line: line, column: column, length: 1, position: initialPosition } });
                        position++;
                        column++;
                    }

                case '$':
                    appendToken({ kind: TokenKind.Dollar, value: "$", info: { line: line, column: column, length: 1, position: initialPosition } });
                    position++;
                    column++;

                case '"':
                    var start = position;
                    position++;
                    column++;
                    while (position < length && source.charAt(position) != '"') {
                        if (source.charAt(position) == '\\') {
                            position++;
                            column++;
                        }
                        position++;
                        column++;
                    }

                    position++;
                    column++;

                    if (position < length) {
                        appendToken({ kind: TokenKind.StringLiteral, value: source.substr(start + 1, position - start - 2), info: { line: line, column: column, length: position - start, position: initialPosition } });
                    } else {
                        context.emitError(module, TokenizerUnterminatedString({
                            line: line,
                            column: column,
                            length: position - start,
                            position: initialPosition
                        }));
                    }

                case '\'':
                    var start = position;
                    position++;
                    column++;
                    while (position < length && source.charAt(position) != '\'') {
                        if (source.charAt(position) == '\\') {
                            position++;
                            column++;
                        }
                        position++;
                        column++;
                    }

                    position++;
                    column++;

                    if (position < length) {
                        appendToken({ kind: TokenKind.StringLiteral, value: source.substr(start + 1, position - start - 2), info: { line: line, column: column, length: position - start, position: initialPosition } });
                    } else {
                        context.emitError(module, TokenizerUnterminatedString({
                            line: line,
                            column: column,
                            length: position - start,
                            position: initialPosition
                        }));
                    }

                case '.':
                    if (source.charAt(position + 1) == '.' && source.charAt(position + 2) == '.') {
                        appendToken({ kind: TokenKind.Spread, value: "...", info: { line: line, column: column, length: 3, position: initialPosition } });
                        position += 3;
                        column += 3;
                    } else {
                        appendToken({ kind: TokenKind.Dot, value: ".", info: { line: line, column: column, length: 1, position: initialPosition } });
                        position++;
                        column++;
                    }

                default:
                    var charCode = char.charCodeAt(0);
                    if (charCode >= 48 && charCode <= 57) {
                        var start = position;
                        var hasDot = false;
                        while (position < length && (isDigit(source.charCodeAt(position)) || (!hasDot && source.charAt(position) == '.'))) {
                            if (source.charAt(position) == '.') {
                                hasDot = true;
                            }
                            position++;
                            column++;
                        }
                        var value = source.substr(start, position - start);
                        if (hasDot) {
                            appendToken({ kind: TokenKind.FloatLiteral, value: value, info: { line: line, column: column, length: position - start, position: initialPosition } });
                        } else {
                            appendToken({ kind: TokenKind.IntegerLiteral, value: value, info: { line: line, column: column, length: position - start, position: initialPosition } });
                        }
                    } else if (charCode >= 65 && charCode <= 90 || charCode >= 97 && charCode <= 122 || charCode == 95) { // A-Z, a-z, _
                        var start = position;
                        while (position < length && (isLetter(source.charCodeAt(position)) || isDigit(source.charCodeAt(position)) || source.charAt(position) == '_')) {
                            position++;
                            column++;
                        }
                        var value = source.substr(start, position - start);
                        var lower = value.toLowerCase();

                        if (lower == "true" || lower == "false") {
                            appendToken({ kind: TokenKind.BooleanLiteral, value: lower, info: { line: line, column: column, length: position - start, position: initialPosition } });
                        } else {
                            appendToken({ kind: TokenKind.Identifier, value: value, info: { line: line, column: column, length: position - start, position: initialPosition } });
                        }
                    } else {
                        position++;
                        column++;

                        if (charCode == null) {
                            continue;
                        }

                        context.emitError(module, TokenizerInvalidCharacter(charCode, {
                            line: line,
                            column: column,
                            length: 1,
                            position: initialPosition
                        }));
                    }

            }
        }

        return tokens;
    }

    private function isDigit(charCode: Int): Bool {
        return charCode >= 48 && charCode <= 57;
    }

    private function isLetter(charCode: Int): Bool {
        return (charCode >= 65 && charCode <= 90) || (charCode >= 97 && charCode <= 122);
    }

}
