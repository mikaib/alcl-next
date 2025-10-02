package alcl.analyzer;

import alcl.parser.Node;

class AnalyzerSolver {

    public var typer: AnalyzerTyper;
    public var pendingConstraints: Array<AnalyzerConstraint> = [];
    public var allConstraints: Array<AnalyzerConstraint> = [];
    public var validCasts: Array<AnalyzerCastMethod> = [];

    public function new(analyzer: AnalyzerTyper) {
        this.typer = analyzer;

        // numerical conversions
        addCastMethod({ from: AnalyzerType.TInt, to: AnalyzerType.TFloat, handler: AnalyzerCastImpl.numericConv });
        addCastMethod({ from: AnalyzerType.TInt, to: AnalyzerType.TDouble, handler: AnalyzerCastImpl.numericConv });
        addCastMethod({ from: AnalyzerType.TInt, to: AnalyzerType.TLong, handler: AnalyzerCastImpl.numericConv });
        addCastMethod({ from: AnalyzerType.TFloat, to: AnalyzerType.TDouble, handler: AnalyzerCastImpl.numericConv });
        addCastMethod({ from: AnalyzerType.TFloat, to: AnalyzerType.TInt, handler: AnalyzerCastImpl.numericConv });
        addCastMethod({ from: AnalyzerType.TFloat, to: AnalyzerType.TLong, handler: AnalyzerCastImpl.numericConv });
        addCastMethod({ from: AnalyzerType.TDouble, to: AnalyzerType.TFloat, handler: AnalyzerCastImpl.numericConv });
        addCastMethod({ from: AnalyzerType.TDouble, to: AnalyzerType.TInt, handler: AnalyzerCastImpl.numericConv });
        addCastMethod({ from: AnalyzerType.TDouble, to: AnalyzerType.TLong, handler: AnalyzerCastImpl.numericConv });
        addCastMethod({ from: AnalyzerType.TLong, to: AnalyzerType.TInt, handler: AnalyzerCastImpl.numericConv });
        addCastMethod({ from: AnalyzerType.TLong, to: AnalyzerType.TFloat, handler: AnalyzerCastImpl.numericConv });
        addCastMethod({ from: AnalyzerType.TLong, to: AnalyzerType.TDouble, handler: AnalyzerCastImpl.numericConv });

        // string <-> cstring conversions
        addCastMethod({ from: AnalyzerType.TString, to: AnalyzerType.TCString, handler: AnalyzerCastImpl.implicitConv });
        addCastMethod({ from: AnalyzerType.TCString, to: AnalyzerType.TString, handler: AnalyzerCastImpl.implicitConv });

        // x -> cstring conversions
        addCastMethod({ from: AnalyzerType.TInt, to: AnalyzerType.TCString, handler: AnalyzerCastImpl.createRuntimeConv("i32_to_cstr", "conv") });
        addCastMethod({ from: AnalyzerType.TLong, to: AnalyzerType.TCString, handler: AnalyzerCastImpl.createRuntimeConv("i64_to_cstr", "conv") });
        addCastMethod({ from: AnalyzerType.TFloat, to: AnalyzerType.TCString, handler: AnalyzerCastImpl.createRuntimeConv("f32_to_cstr", "conv") });
        addCastMethod({ from: AnalyzerType.TDouble, to: AnalyzerType.TCString, handler: AnalyzerCastImpl.createRuntimeConv("f64_to_cstr", "conv") });
        addCastMethod({ from: AnalyzerType.TBool, to: AnalyzerType.TCString, handler: AnalyzerCastImpl.createRuntimeConv("bool_to_cstr", "conv") });
    }

    public function addCastMethod(cst: AnalyzerCastMethod): Void {
        validCasts.push(cst);
    }

    public function findCast(from: AnalyzerType, to: AnalyzerType): Array<AnalyzerType> {
        if (from.eq(to)) {
            return [];
        }

        for (cst in validCasts) {
            if (cst.from.eq(from) && cst.to.eq(to)) {
                return [from, to];
            }
        }

        var queue: Array<{type: AnalyzerType, path: Array<AnalyzerType>}> = [{type: from, path: [from]}];
        var visited: Map<String, Bool> = new Map();
        visited.set(from.toString(), true);

        while (queue.length > 0) {
            var current = queue.shift();

            for (cst in validCasts) {
                if (cst.from.eq(current.type)) {
                    var nextType = cst.to;
                    var typeKey = nextType.toString();

                    if (!visited.exists(typeKey)) {
                        visited.set(typeKey, true);
                        var newPath = current.path.copy();
                        newPath.push(nextType);

                        if (nextType.eq(to)) {
                            return newPath;
                        }

                        queue.push({type: nextType, path: newPath});
                    }
                }
            }
        }

        return [];
    }

    public function addConstraint(constraint: AnalyzerConstraint): Void {
        pendingConstraints.push(constraint);
        allConstraints.push(constraint);
    }

    public function nodeMustMatchNode(want: Node, have: Node, scope: AnalyzerScope): AnalyzerType {
        var v: AnalyzerConstraint = {
            want: AnalyzerPair.fromNode(want, typer.getType(want, scope)),
            have: AnalyzerPair.fromNode(have, typer.getType(have, scope))
        };

        addConstraint(v);
        return v.result;
    }

    public function nodeMustMatchNodeRes(want: Node, have: Node, resType: AnalyzerType, scope: AnalyzerScope): AnalyzerType {
        var v: AnalyzerConstraint = {
            want: AnalyzerPair.fromNode(want, typer.getType(want, scope)),
            have: AnalyzerPair.fromNode(have, typer.getType(have, scope)),
            result: resType
        };

        addConstraint(v);
        return v.result;
    }

    public function nodeMustMatchType(want: AnalyzerType, have: Node, scope: AnalyzerScope): AnalyzerType {
        var v: AnalyzerConstraint = {
            want: AnalyzerPair.fromType(want),
            have: AnalyzerPair.fromNode(have, typer.getType(have, scope))
        };

        addConstraint(v);
        return v.result;
    }

    public function nodeMustMatchTypeVerbose(want: AnalyzerType, haveType: AnalyzerType, haveNode: Node, scope: AnalyzerScope, explicit: Bool = false): AnalyzerType {
        var v: AnalyzerConstraint = {
            want: AnalyzerPair.fromType(want),
            have: AnalyzerPair.fromNode(haveNode, haveType),
            explicit: explicit
        };

        addConstraint(v);
        return v.result;
    }

    public function nodeMustMatchTypeVerboseRes(want: AnalyzerType, haveType: AnalyzerType, resType: AnalyzerType, haveNode: Node, scope: AnalyzerScope, explicit: Bool = false): AnalyzerType {
        var v: AnalyzerConstraint = {
            want: AnalyzerPair.fromType(want),
            have: AnalyzerPair.fromNode(haveNode, haveType),
            result: resType,
            explicit: explicit
        };

        addConstraint(v);
        return v.result;
    }

    public function typeMustMatchType(want: AnalyzerType, have: AnalyzerType): AnalyzerType {
        var v: AnalyzerConstraint = {
            want: AnalyzerPair.fromType(want),
            have: AnalyzerPair.fromType(have)
        };

        addConstraint(v);
        return v.result;
    }

    public function unify(c: AnalyzerConstraint): Bool {
        // if both are unknown, we can't unify
        if (c.want.type.isUnknown() && c.have.type.isUnknown()) {
            return false;
        }

        // the type we want may not be pending a resolve
        if (c.want.type.isDependant() || c.have.type.isDependant()) {
            return false;
        }

        // if want is unknown, we can take it from have
        if (c.want.type.isUnknown()) {
            c.result.set(c.have.type);
            c.want.type.set(c.result);
            return true;
        }

        // if have is unknown, we can take it from want
        if (c.have.type.isUnknown()) {
            c.result.set(c.want.type);
            c.have.type.set(c.result);
            return true;
        }

        // if they are the same type, we can unify
        if (c.want.type.eq(c.have.type)) {
            c.result.set(c.want.type);
            return true;
        }

        // if either type is any, we can unify without casting
        if (c.want.type.eq(AnalyzerType.TAny) || c.have.type.eq(AnalyzerType.TAny)) {
            c.result.set(c.have.type);
            return true;
        }

        // check if a cast is possible
        if (tryCast(c)) {
            return true;
        }

        // no unification possible
        return false;
    }

    public function tryCast(c: AnalyzerConstraint): Bool {
        var castChain = findCast(c.have.type, c.want.type);
        if (castChain.length >= 2) {
            var currentConstraint = c.copy();

            for (i in 1...castChain.length) {
                var fromType = castChain[i - 1];
                var toType = castChain[i];

                for (cst in validCasts) {
                    if (cst.from.eq(fromType) && cst.to.eq(toType)) {
                        var stepConstraint: AnalyzerConstraint = {
                            want: AnalyzerPair.fromNode(c.want?.node, toType),
                            have: AnalyzerPair.fromNode(c.have?.node, c.have?.type),
                            explicit: c.explicit
                        };

                        if (currentConstraint.have.node != null) {
                            stepConstraint.have.node = currentConstraint.have.node;
                        }

                        if (cst.handler(stepConstraint, this)) {
                            currentConstraint.have.type.set(toType);
                        }
                    }
                }
            }

            // final
            c.result.set(c.want.type);
            c.have.type.set(c.want.type);
            return true;
        }

        return false;
    }

    public function iter(): Bool {
        var removalQueue: Array<AnalyzerConstraint> = [];

        for (c in pendingConstraints) {
            if (unify(c)) {
                removalQueue.push(c);
                continue;
            }
        }

        for (r in removalQueue) {
            pendingConstraints.remove(r);
        }

        return removalQueue.length > 0;
    }

    public function solve(): Bool {
        while (iter()) {}

        if (pendingConstraints.length == 0) {
            return true;
        }

        for (c in pendingConstraints) {
            typer.context.emitError(typer.module, AnalyzerTypeMismatch(c));
        }

        return false;
    }

}
