package alcl.parser;

import alcl.tokenizer.Token;
import alcl.Error;

class Parser {

    private var context: Context;
    private var ast: AST;
    private var paths: Array<ParserPath>;
    private var pos: Int = 0;
    private var module: Module;

    public function new(module: Module, context: Context, tokens: Array<Token>, isInline: Bool = false, doRun: Bool = true) {
        this.context = context;
        this.module = module;
        this.pos = 0;
        this.paths = [
            // reify
            new alcl.parser.paths.ReifyPath(),

            // cast
            new alcl.parser.paths.CastPath(),

            // ternary
            new alcl.parser.paths.TernaryPath(),

            // func
            new alcl.parser.paths.ReturnPath(),
            new alcl.parser.paths.FunctionDeclPath(),
            new alcl.parser.paths.FunctionCallPath(),

            // lit
            new alcl.parser.paths.StringLiteralPath(),
            new alcl.parser.paths.IntegerLiteralPath(),
            new alcl.parser.paths.FloatLiteralPath(),
            new alcl.parser.paths.BooleanLiteralPath(),

            // vars
            new alcl.parser.paths.VariableDeclPath(),

            // typeless
            new alcl.parser.paths.UntypedPath(),

            // binop
            new alcl.parser.paths.BinaryOperationPath(),

            // compiletime stuff
            new alcl.parser.paths.ImportPath(),
            new alcl.parser.paths.MetaPath(),
            new alcl.parser.paths.SemicolonPath(),

            // ident
            new alcl.parser.paths.IdentifierPath()
        ];

        if (doRun) {
            this.ast = exec(tokens, pos, isInline);
        }
    }

    public function run(tokens: Array<Token>): AST {
        this.ast = exec(tokens, pos, false);
        return ast;
    }

    public function getAST(): AST {
        return ast;
    }

    public function getContext(): Context {
        return context;
    }

    public function getModule(): Module {
        return module;
    }

    public function popMetas(currentAst: AST): Array<Node> {
        var metas: Array<Node> = [];
        var off: Int = 1;

        while (currentAst.length - off >= 0) {
            var last: Node = currentAst[currentAst.length - off];

            if (last != null && last.kind.match(NodeKind.Meta(_))) {
                metas.push(last);
                off++;
            } else {
                break;
            }
        }

        return metas;
    }

    public function exec(tokens: Array<Token>, localPos: Int, isInline: Bool = false): AST {
        var ast: AST = [];
        var desc: ParserExecDesc = {
            parser: this,
            tokens: tokens,
            tokenIndex: localPos,
            isInline: isInline,
            ast: ast
        };

        while (localPos < tokens.length) {
            var found: Bool = false;
            desc.tokenIndex = localPos;

            for (path in paths) {
                path.exec(desc);

                if (path.success) {
                    if (path.submitted) {
                        ast.push(path.result);
                    }

                    localPos = path.currentPos;
                    found = true;

                    break;
                }
            }

            if (!found) {
                context.emitError(module, ParserUnexpectedToken(tokens[localPos]));
                break;
            }
        }

        return ast;
    }

    public function execUntilFirst(tokens: Array<Token>, localPos: Int, isInline: Bool = false): { node: Node, advance: Int } {
        var ast: AST = [];
        var desc: ParserExecDesc = {
            parser: this,
            tokens: tokens,
            tokenIndex: localPos,
            isInline: isInline,
            ast: ast
        };

        while (localPos < tokens.length) {
            desc.tokenIndex = localPos;

            for (path in paths) {
                path.exec(desc);

                if (path.success) {
                    if (path.submitted) {
                        ast.push(path.result);
                        return { node: ast[0], advance: path.currentPos - localPos  };
                    }

                    localPos = path.currentPos;
                    break;
                }
            }

            if (ast.length > 0) {
                return { node: ast[0], advance: localPos  };
            }

            context.emitError(module, ParserUnexpectedToken(tokens[localPos]));
        }

        return { node: null, advance: 0 };
    }

}
