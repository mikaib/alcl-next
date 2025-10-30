package;

import alcl.Context;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import haxe.CallStack.CallStack.callStack;
import haxe.CallStack;
import haxe.CallStack.CallStack.toString;

using alcl.ErrorUtil;
using alcl.WarningUtil;

class Main {

    static public function createRoot(name: String) {
        return Path.join([Sys.getCwd(), name]);
    }

    static public function ensureDirectoryExists(path: String) {
        var parts = path.split("/");
        var current = "";

        for (part in parts) {
            current += part + "/";
            if (!FileSystem.exists(current)) {
                FileSystem.createDirectory(current);
            }
        }
    }

    static public function ensureWrite(path: String, content: String) {
        var dir = Path.directory(path);
        ensureDirectoryExists(dir);

        if (FileSystem.exists(path)) { // TODO: use a cache instead of reading the file every time
            var existing = File.getContent(path);
            if (existing == content) {
                return;
            }
        }

        File.saveContent(path, content);
    }

    static public function main() {
        // create context with the project settings
        var context = new Context({
            roots: [
                createRoot("RND"),
                createRoot("StdLib")
            ],
        });

        // ensure main module is loaded
        var mainModule = context.main();
        Sys.println(mainModule.typedAst.toString());

        // log warnings
        for (v in context.warnings) {
            var formatted = v.warning.warningToString();
            Sys.println('[WARNING] ${v.module?.path ?? '(internal)'}${formatted.pos != null ? ':${formatted.pos}' : ""} ${formatted.message}');
        }

        // log errors
        for (v in context.errors) {
            var formatted = v.error.errorToString();
            Sys.println('[ERROR] ${v.module?.path ?? '(internal)'}${formatted.pos != null ? ':${formatted.pos}' : ""} ${formatted.message}');
            Sys.println(CallStack.toString(CallStack.callStack()));
        }

        // exit if there were errors
        if (context.errors.length > 0) {
            Sys.exit(1);
        }

        // create output dir
        var output = context.options.outputDirectory;
        ensureDirectoryExists(output);

        // export modules
        var modules = context.getModules();
        for (module in modules) {
            var source = module.getNativeSource(context.generatorContext);
            var header = module.getNativeHeader(context.generatorContext);

            var outDir = Path.join([output, 'Source']);
            ensureDirectoryExists(outDir);

            var outSourcePath = Path.join([outDir, module.getPathSource()]);
            var outHeaderPath = Path.join([outDir, module.getPathHeader()]);

            ensureWrite(outSourcePath, source);
            ensureWrite(outHeaderPath, header);
        }

        // create cmake
        var cmakePath = Path.join([output, "CMakeLists.txt"]);
        ensureWrite(cmakePath, context.getBuildConfig());
    }

}
