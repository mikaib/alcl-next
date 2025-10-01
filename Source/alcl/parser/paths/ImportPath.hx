package alcl.parser.paths;

import alcl.tokenizer.TokenKind;
import alcl.parser.ParserPath;

class ImportPath extends ParserPath {

    override public function onRun(): Void {
        expectKindAndValue(Identifier, "import");
        var moduleName = expectKind(StringLiteral);

        if (!success) {
            return;
        }

        parser.getModule().addImport(moduleName.value);
    }

}
