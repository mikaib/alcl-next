package alcl;

import alcl.tokenizer.Tokenizer;
import alcl.parser.Parser;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import alcl.analyzer.AnalyzerTyper;

class ModuleResolver {

    private var context: Context;
    private var cache: Map<String, Module> = [];

    public function new(context: Context) {
        this.context = context;
    }

    public function getPath(module: String): String {
        for (root in context.options.roots) {
            var path = Path.join([root, module + ".alcl"]);
            if (FileSystem.exists(path)) {
                return path;
            }
        }

        return null;
    }

    public function exists(module: String): Bool {
        var path = getPath(module);
        return path != null ? FileSystem.exists(path) : false;
    }

    public function readContent(module: String): String {
        var path = getPath(module);
        return path != null ? File.getContent(path) : "";
    }

    public function getAllModules(): Array<Module> {
        return Lambda.array(cache);
    }

    public function getOrCreateModule(module: String): Module {
        if (cache.exists(module)) {
            return cache.get(module);
        }

        var path = getPath(module);
        if (path == null) {
            context.emitError(null, ModuleNotFound(module));
            return null;
        }

        var moduleObj: Module = {
            name: module,
            path: path,
            typer: null,
            tokenizer: null,
            parser: null,
            typedAst: null
        };

        moduleObj.tokenizer = new Tokenizer(moduleObj, context, readContent(module), context.options.defines);
        moduleObj.parser = new Parser(moduleObj, context, [], false, false);
        moduleObj.typer = new AnalyzerTyper(moduleObj);

        var tokens = moduleObj.tokenizer.run();
        var parsed = moduleObj.parser.run(tokens);
        var analyzed = moduleObj.typer.run(parsed);

        moduleObj.typedAst = analyzed;
        cache.set(moduleObj.name, moduleObj);

        return moduleObj;
    }

}
