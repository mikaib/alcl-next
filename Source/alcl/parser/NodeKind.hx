package alcl.parser;

import alcl.analyzer.AnalyzerFunction;
import alcl.analyzer.AnalyzerType;
import alcl.analyzer.AnalyzerVariable;

enum NodeKind {
    // func
    FunctionDecl(desc: AnalyzerFunction);
    FunctionCall(name: String, remappedName: String, returnType: AnalyzerType);
    MacroFunctionCall(name: String, remappedName: String, returnType: AnalyzerType);
    Return;

    // lit
    StringLiteralNode(value: String);
    IntegerLiteralNode(value: String);
    FloatLiteralNode(value: String);
    BooleanLiteralNode(value: String);

    // vars
    VarDecl(desc: AnalyzerVariable);

    // identifiers
    IdentifierNode(name: String, resType: AnalyzerType);

    // compiler features
    CCode(code: String);
    CCast(type: AnalyzerType); // raw C casting
    Cast(type: AnalyzerType); // alcl casting
    Meta(type: String);

    // operations
    BinaryOperation(op: String, resType: AnalyzerType);
}
