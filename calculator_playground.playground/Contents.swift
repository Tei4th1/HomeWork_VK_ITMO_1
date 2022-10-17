import Foundation

protocol Calculator<Number> {
    associatedtype Number: Numeric
    
    init(operators: Dictionary<String, Operator<Number>>)
    
    func evaluate(_ input: String) throws -> Number
}

enum CalcErrors: Error {
    case conversionFailed
    case cannotFindSign
    case signIsFirstOrLast
    case unexpectedError
    case incorrectInput
}

enum Associativity {
    case left
    case right
}

struct Operator<T> {
    let precedence: Int
    let associativity: Associativity
    let function: (T, T) -> T
}

struct AnyCalculator<T: Numeric & LosslessStringConvertible>: Calculator {
    typealias Number = T
    private let signDictionary: [String: Operator<T>]
    
    init(operators: Dictionary<String, Operator<T>>) {
        signDictionary = operators
    }
    
    func evaluate(_ input: String) throws -> T {
        var components = input.split(separator: " ").map { String($0) }
        guard !components.isEmpty else { throw CalcErrors.incorrectInput }
        
        while components.count > 1 {
            var maxPrecedence = Int.min
            var maxPrecedenceIndex = -1
            
            for i in 0..<components.count {
                if let oper = signDictionary[components[i]], oper.precedence > maxPrecedence || oper.precedence == maxPrecedence && oper.associativity == .right {
                    maxPrecedence = oper.precedence
                    maxPrecedenceIndex = i
                }
            }
    
            guard maxPrecedenceIndex != -1 else { throw CalcErrors.cannotFindSign }
            guard maxPrecedenceIndex != 0 && maxPrecedenceIndex != components.count - 1 else { throw CalcErrors.signIsFirstOrLast }
            
            guard let signOperator = signDictionary[components[maxPrecedenceIndex]] else { throw CalcErrors.unexpectedError }
            
            let leftToken = components[maxPrecedenceIndex - 1]
            guard let leftArgument = T(leftToken) else { throw CalcErrors.conversionFailed }
            
            let rightToken = components[maxPrecedenceIndex + 1]
            guard let rightArgument = T(rightToken) else { throw CalcErrors.conversionFailed }

            let result = signOperator.function(leftArgument, rightArgument)
            components.replaceSubrange(maxPrecedenceIndex - 1...maxPrecedenceIndex + 1, with: [String(result)])
        }
        guard let result = T(components[0]) else { throw CalcErrors.conversionFailed }
        return result
    }
}

typealias IntegerCalculator = AnyCalculator<Int>
typealias RealCalculator = AnyCalculator<Double>

func test(calculator type: (some Calculator<Double>).Type) {
    let calculator = type.init(operators: [
        "+": Operator(precedence: 10, associativity: .left, function: +),
        "-": Operator(precedence: 10, associativity: .left, function: -),
        "*": Operator(precedence: 20, associativity: .left, function: *),
        "/": Operator(precedence: 20, associativity: .left, function: /),
    ])
    
    let result1 = try! calculator.evaluate("2.2 + 200.12 * 2.0 + 2.0 / 2.0")
    print(result1)
    assert(result1 == 403.44)
}
test(calculator: RealCalculator.self)
