import Foundation

func _isCloseTo(actualValue: Double?, expectedValue: Double, delta: Double, failureMessage: FailureMessage) -> Bool {
    failureMessage.postfixMessage = "be close to <\(stringify(expectedValue))> (within \(stringify(delta)))"
    if actualValue {
        failureMessage.actualValue = "<\(stringify(actualValue!))>"
    } else {
        failureMessage.actualValue = "<nil>"
    }
    return actualValue && abs(actualValue! - expectedValue) < delta
}

func beCloseTo(expectedValue: Double, within delta: Double = 0.0001) -> MatcherFunc<Double> {
    return MatcherFunc { actualExpression, failureMessage in
        return _isCloseTo(actualExpression.evaluate(), expectedValue, delta, failureMessage)
    }
}

func beCloseTo(expectedValue: KICDoubleConvertible, within delta: Double = 0.0001) -> MatcherFunc<KICDoubleConvertible?> {
    return MatcherFunc { actualExpression, failureMessage in
        return _isCloseTo(actualExpression.evaluate()?.doubleValue, expectedValue.doubleValue, delta, failureMessage)
    }
}

@objc class KICObjCBeCloseToMatcher : KICMatcher {
    var _expected: NSNumber
    var _delta: CDouble
    init(expected: NSNumber, within: CDouble) {
        _expected = expected
        _delta = within
    }

    func matches(actualExpression: () -> NSObject!, failureMessage: FailureMessage, location: SourceLocation) -> Bool {
        let actualBlock: () -> KICDoubleConvertible? = ({
            return actualExpression() as? KICDoubleConvertible
        })
        let expr = Expression(expression: actualBlock, location: location)
        return beCloseTo(self._expected, within: self._delta).matches(expr, failureMessage: failureMessage)
    }

    var within: (CDouble) -> KICObjCBeCloseToMatcher {
        return ({ delta in
            return KICObjCBeCloseToMatcher(expected: self._expected, within: delta)
        })
    }
}

extension KICObjCMatcher {
    class func beCloseToMatcher(expected: NSNumber, within: CDouble) -> KICObjCBeCloseToMatcher {
        return KICObjCBeCloseToMatcher(expected: expected, within: within)
    }
}