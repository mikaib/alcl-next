package alcl.eval.std;

import alcl.analyzer.AnalyzerType;

class EvalStdConv implements IEvalStd {

    @alcl_std
    public static function alcl_conv_i32_to_cstr(context: EvalContext, args: Array<EvalValue>): EvalValue {
        return context.castValue(args[0], AnalyzerType.TString);
    }

    @alcl_std
    public static function alcl_conv_i64_to_cstr(context: EvalContext, args: Array<EvalValue>): EvalValue {
        return context.castValue(args[0], AnalyzerType.TString);
    }

    @alcl_std
    public static function alcl_conv_f32_to_cstr(context: EvalContext, args: Array<EvalValue>): EvalValue {
        return context.castValue(args[0], AnalyzerType.TString);
    }

    @alcl_std
    public static function alcl_conv_f64_to_cstr(context: EvalContext, args: Array<EvalValue>): EvalValue {
        return context.castValue(args[0], AnalyzerType.TString);
    }

    @alcl_std
    public static function alcl_conv_bool_to_cstr(context: EvalContext, args: Array<EvalValue>): EvalValue {
        return context.castValue(args[0], AnalyzerType.TString);
    }

}