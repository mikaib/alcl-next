package alcl;

import alcl.analyzer.AnalyzerConstraint;
import alcl.analyzer.AnalyzerType;

enum Warning {
    AnalyzerNarrowingConversion(from: AnalyzerType, to: AnalyzerType, c: AnalyzerConstraint);
}
