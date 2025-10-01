package;
import alcl.Context;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;

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
        var module = context.main();

        // eval it
        var ev = context.eval(module);
        var res = ev.run();

        // print results
        Sys.println('\n' + module.typedAst.toString());
        Sys.println('Result (${res.type.toHumanReadableString()}): ${res.value}');

        // exit early
        return;

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
