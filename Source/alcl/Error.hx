package alcl;

import alcl.tokenizer.TokenInfo;
import alcl.tokenizer.TokenKind;
import alcl.tokenizer.Token;
import alcl.parser.NodeInfo;
import alcl.parser.Node;
import alcl.analyzer.AnalyzerType;
import alcl.analyzer.AnalyzerConstraint;

enum Error {
    ModuleNotFound(module: String);
    ParserExpectedToken(token: TokenKind, info: NodeInfo);
    ParserUnexpectedToken(token: Token);
    ParserUnmatchedParenthesis(info: TokenInfo);
    ParserUnknownMeta(meta: String, info: NodeInfo);
    ParserInvalidMetaArgument(arg: Node, meta: String, info: NodeInfo);
    TokenizerPreprocessorError(message: String, info: TokenInfo);
    TokenizerUnterminatedString(info: TokenInfo);
    TokenizerInvalidCharacter(char: Int, info: TokenInfo);
    AnalyzerUnknownFunction(name: String, info: NodeInfo);
    AnalyzerUnknownVariable(name: String, info: NodeInfo);
    AnalyzerUnknownType(name: AnalyzerType, info: NodeInfo);
    AnalyzerTypeMismatch(constraint: AnalyzerConstraint);
    AnalyzerReturnOutsideFunction(info: NodeInfo);
    AnalyzerInvalidConversionFunction(name: String, info: NodeInfo);
    AnalyzerInvalidCast(from: AnalyzerType, to: AnalyzerType, info: NodeInfo);
}
