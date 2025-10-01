package alcl.eval.std;

import alcl.analyzer.AnalyzerType;

class EvalStdIo implements IEvalStd {

    @alcl_std
    public static function alcl_io_println(context: EvalContext, args: Array<EvalValue>): EvalValue {
        var str = context.castValue(args[0], AnalyzerType.TString);
        Sys.println(str.value);

        return { type: AnalyzerType.TVoid, value: 0 };
    }

}