package alcl;
import alcl.cgen.GeneratorContext;
import alcl.cgen.GeneratorBuffer;
import haxe.io.Path;
import haxe.CallStack;
import alcl.eval.EvalContext;

class Context {

    public var options: ContextOptions;
    public var generatorContext: GeneratorContext;
    public var moduleResolver: ModuleResolver;
    public var errors: Array<{ module: Module, error: Error }>;
    public var warnings: Array<{ module: Module, warning: Warning }>;

    public function new(options: ContextOptions) {
        this.options = options;
        this.moduleResolver = new ModuleResolver(this);
        this.generatorContext = new GeneratorContext(this);
        this.errors = [];
        this.warnings = [];
    }

    public inline function module(module: String): Module {
        return moduleResolver.getOrCreateModule(module);
    }

    public inline function eval(module: Module): EvalContext {
        return new EvalContext(module.typedAst, module);
    }

    public inline function main(): Module {
        return module(options.main);
    }

    public inline function getModules(): Array<Module> {
        return moduleResolver.getAllModules();
    }

    public function getBuildConfig(): String {
        var buf = new GeneratorBuffer();
        var projName = options.projectName == "" ? "alcl_project" : options.projectName;

        buf.println('cmake_minimum_required(VERSION 3.10)');
        buf.println('project(${projName})');
        buf.println('set(CMAKE_C_STANDARD 11)');
        buf.println('set(CMAKE_C_STANDARD_REQUIRED True)');
        buf.println('');
        buf.println('add_executable(${projName}');
        for (module in getModules()) {
            buf.println('./' + Path.join(['./Source', '${module.getPathSource()}']), 1);
        }
        buf.println(')');
        buf.println('');

        var headerDirs = new Map<String, Bool>();
        for (module in getModules()) {
            var headerPath = module.getPathHeader();
            if (headerPath != null) {
                var dir = Path.directory('./' + Path.join(['./Source', headerPath]));
                headerDirs.set(dir, true);
            }
        }

        for (dir in headerDirs.keys()) {
            buf.println('target_include_directories(${projName} PRIVATE ${dir})');
        }

        buf.println('');

        return buf;
    }

    public function emitError(module: Module, error: Error): Void {
        errors.push({ module: module, error: error });
    }

    public function emitWarning(module: Module, warning: Warning): Void {
        warnings.push({ module: module, warning: warning });
    }

}
