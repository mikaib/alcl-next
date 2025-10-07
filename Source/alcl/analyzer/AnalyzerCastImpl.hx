package alcl.analyzer;

class AnalyzerCastImpl {

    private static final narrowingConversionMap: Map<String, Bool> = [
        narrowingKey(AnalyzerType.TDouble, AnalyzerType.TFloat) => true,
        narrowingKey(AnalyzerType.TDouble, AnalyzerType.TInt) => true,
        narrowingKey(AnalyzerType.TDouble, AnalyzerType.TLong) => true,
        narrowingKey(AnalyzerType.TFloat, AnalyzerType.TInt) => true,
        narrowingKey(AnalyzerType.TFloat, AnalyzerType.TLong) => true,
        narrowingKey(AnalyzerType.TLong, AnalyzerType.TInt) => true,
        narrowingKey(AnalyzerType.TLong, AnalyzerType.TFloat) => true,
        narrowingKey(AnalyzerType.TLong, AnalyzerType.TDouble) => true,
    ];

    private static function narrowingKey(have: AnalyzerType, want: AnalyzerType): String {
        return have.toString() + "->" + want.toString();
    }

    private static function isNarrowingConversion(from: AnalyzerType, to: AnalyzerType): Bool {
        return narrowingConversionMap.exists(narrowingKey(from, to));
    }

    public static function numericConv(constraint: AnalyzerConstraint, solver: AnalyzerSolver): Bool {
        if (isNarrowingConversion(constraint.have.type, constraint.want.type)) {
            if (constraint.want.node != null && constraint.have.node != null) {
                var flipped = constraint.flipped();
                if (!isNarrowingConversion(flipped.have.type, flipped.want.type)) {
                    return numericConv(flipped, solver);
                }
            }

            if (!constraint.explicit) solver.typer.context.emitWarning(
                solver.typer.module,
                AnalyzerNarrowingConversion(constraint.have.type.copy(), constraint.want.type.copy(), constraint)
            );
        }

        if (constraint.have.node == null) {
            return false;
        }

        constraint.result.set(constraint.want.type);
        constraint.have.type.set(constraint.want.type);

        constraint.have.node.wrap({
            kind: CCast(constraint.want.type),
            info: constraint.have.node.info
        });

        return true;
    }

    public static function explicitConv(constraint: AnalyzerConstraint, solver: AnalyzerSolver): Bool {
        constraint.result.set(constraint.want.type);
        constraint.have.type.set(constraint.want.type);

        constraint.have.node.wrap({
            kind: CCast(constraint.want.type),
            info: constraint.have.node.info
        });

        return true;
    }

    public static function implicitConv(constraint: AnalyzerConstraint, solver: AnalyzerSolver): Bool {
        constraint.result.set(constraint.want.type);
        constraint.have.type.set(constraint.want.type);

        return true;
    }

    public static function toPtrConv(constraint: AnalyzerConstraint, solver: AnalyzerSolver): Bool {
        return true;
    }

    public static function fromPtrConv(constraint: AnalyzerConstraint, solver: AnalyzerSolver): Bool {
        return true;
    }

    public static function createRuntimeConv(funcName: String, libName: String): (AnalyzerConstraint, AnalyzerSolver) -> Bool {
        return (constraint: AnalyzerConstraint, solver: AnalyzerSolver) -> {
            var module = solver.typer.module;
            var context = solver.typer.context;

            var lib = context.module(libName);
            var fn = lib.typer.globalScope.findFunction(funcName);

            if (fn == null) {
                context.emitError(module, AnalyzerUnknownFunction(funcName, constraint.have.node.info));
                return false;
            }

            if (fn.parameters.length != 1) {
                context.emitError(module, AnalyzerInvalidConversionFunction(funcName, constraint.have.node.info));
                return false;
            }

            module.addImport(libName);

            constraint.result.set(constraint.want.type);
            constraint.have.type.set(constraint.want.type);

            constraint.have.node.wrap({
                kind: FunctionCall(fn.name, fn.remappedName, fn.returnType.copy()), // TODO: check if the copy() will cause issues...
                children: [],
                info: constraint.have.node.info
            });

            return false;
        };
    }

}
