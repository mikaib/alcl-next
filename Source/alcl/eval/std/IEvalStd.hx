package alcl.eval.std;

#if (macro)
import haxe.macro.Expr.Field;
import haxe.macro.Expr;
import haxe.macro.Context;

class _IEvalStdMacro {
    private static var funcMap: Map<String, Array<String>> = new Map();

    public static function build(): Array<Field> {
        var fields = Context.getBuildFields();
        var localClass = Context.getLocalClass().get();
        var className = localClass.pack.concat([localClass.name]).join(".");

        for (field in fields) {
            if (field.meta.filter((m) -> m.name == "alcl_std").length > 0) {
                funcMap.set(field.name, className.split("."));
            }
        }

        return fields;
    }

    public static function buildFuncMapExpr(): Array<Expr> {
        var mapExprs: Array<Expr> = [];

        for (name => classPath in funcMap) {
            var fieldName = name;
            mapExprs.push(macro $v{name} => $p{classPath.concat([fieldName])} );
        }

        return mapExprs;
    }
}
#end

@:autoBuild(alcl.eval.std.IEvalStd._IEvalStdMacro.build())
interface IEvalStd {}

class IEvalStdRuntime {
    private static var _funcMap: Map<String, Dynamic>;

    public static function getFunction(name: String): Dynamic {
        if (_funcMap == null) {
            _funcMap = _initFuncMap();
        }
        return _funcMap.get(name);
    }

    public static function getFunctionList(): Array<String> {
        if (_funcMap == null) {
            _funcMap = _initFuncMap();
        }

        var items: Array<String> = [];
        for (k in _funcMap.keys()) {
            items.push(k);
        }

        return items;
    }

    private static macro function _initFuncMap(): Expr {
        var mapExprs = _IEvalStdMacro.buildFuncMapExpr();
        return macro [ $a{mapExprs} ];
    }
}