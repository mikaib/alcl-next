package alcl.cgen;

class GeneratorContext {

    private var context: Context;

    public function new(context: Context) {
        this.context = context;
    }

    public function getNativeSource(module: Module): String {
        var content = new Generator(module.typedAst, module).print();
        if (module.name == "main" && module.functions.filter(x -> x.name == "main").length != 0) {
            content += 'int main(int argc, char** argv) {\n    ' + module.getSafeName('main') + '();\n    return 0;\n}\n';
        }

        return content;
    }

    public function getNativeHeader(module: Module): String {
        var buf: GeneratorBuffer = new GeneratorBuffer();
        var guardName =  context.options.projectName.toUpperCase() + "_" + module.name.toUpperCase().split("/").join("_");
        var includeCount = 0;
        var includeMap: Map<String, Bool> = [];

        buf.println('#ifndef ' +  guardName + '_H');
        buf.println('#define ' + guardName + '_H');
        buf.println('');

        for (imp in module.imports) {
            var headerPath = imp.getPathHeader();
            buf.println('#include "' + headerPath + '"');
        }
        if (module.imports.length != 0) buf.println('');

        for (func in module.functions) {
            for (meta in func.metas) {
                if (meta.kind == Include) {
                    var includePath = meta.params[0];
                    if (!includeMap.exists(includePath)) {
                        includeMap.set(includePath, true);
                        buf.println('#include "$includePath"');
                        includeCount++;
                    }
                }
            }
        }
        if (includeCount != 0) buf.println('');

        for (func in module.functions) {
            var retType = func.returnType.toCTypeString();
            var params = func.parameters.map(p -> p.type.toCTypeString() + ' ' + p.name).join(', ');
            buf.println(retType + ' ' + func.remappedName + '(' + params + ');');
        }

        buf.println('');
        buf.println('#endif //' + guardName + '_H');

        return buf.toString();
    }

}
