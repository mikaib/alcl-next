package alcl.parser.paths;

import alcl.tokenizer.TokenKind;
import alcl.parser.ParserPath;
import alcl.analyzer.AnalyzerType;
import alcl.analyzer.AnalyzerParameter;
import alcl.analyzer.AnalyzerMeta;
import alcl.analyzer.AnalyzerFunction;

class FunctionDeclPath extends ParserPath {

    override public function onRun(): Void {
        var isMacro = ifKindAndValue(Identifier, "macro");
        expectKindAndValue(Identifier, "func");

        var name = expectKind(Identifier);
        var paramTokens = expectBlock(LeftParen, RightParen);
        var paramPath = createPath(paramTokens);
        var params: Array<AnalyzerParameter> = [];

        while (paramPath.hasMoreTokens()) {
            if (!paramPath.success) {
                fail();
                return;
            }

            var name = paramPath.expectKind(Identifier);
            var type = AnalyzerType.TUnknown;
            if (paramPath.ifKind(Colon)) {
                type = paramPath.expectType();
            }

            if (paramPath.hasMoreTokens()) paramPath.expectKind(Comma);
            params.push({
                name: name.value,
                type: type
            });
        }

        var returnType = AnalyzerType.Fallback(AnalyzerType.TVoid);
        if (ifKind(Colon)) {
            returnType = expectType();
        }

        var bodyTokens = expectBlock(LeftBrace, RightBrace);

        var body = parse(bodyTokens);
        var module = parser.getModule();
        var info = getCurrentInfo();

        var metasRaw = parser.popMetas(currentAst);

        var metas: Array<AnalyzerMeta> = [];

        for (meta in metasRaw) {
            switch (meta.kind) {
                case Meta(type):
                    if (type == "include") {
                        switch (meta.children[0].kind) {
                            case StringLiteralNode(value):
                               metas.push({
                                   kind: Include,
                                   params: [value]
                               });
                            case _: null;
                        }
                    }
                case _: null;
            }
        }

        if (isMacro) {
            metas.push({
                kind: Macro,
                params: []
            });
        }

        var func: AnalyzerFunction = {
            name: name.value,
            parameters: params,
            returnType: returnType,
            module: module,
            info: info,
            metas: metas
        };

        submitNode({
            kind: FunctionDecl(func),
            info: info,
            children: body
        });
    }

}
