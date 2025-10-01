package alcl.eval.std;

#if (macro)
import haxe.macro.Expr.Field;
import haxe.macro.Expr;

class _IEvalStdMacro {

    public static function build(): Array<Field> {
        var fields = haxe.macro.Context.getBuildFields();

        for (field in fields) {
            if (field.meta.filter((m) -> m.name == "alcl_std").length > 0) {
                // add to some kind of map
            }
        }

        return fields;
    }

    public static function getFuncMap(): Map<String, Dynamic> {
        // allow the retrival of the map here
        return [];
    }

}
#end

@:autoBuild(alcl.eval.std.IEvalStd._IEvalStdMacro.build())
interface IEvalStd {}