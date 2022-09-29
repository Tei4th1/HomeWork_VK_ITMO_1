import Foundation

protocol Calculator<Number>: LosslessStringConvertible {
    associatedtype Number: Numeric
    init(operators: Dictionary<String, Operator<Number>>)
    func evaluate(_ input: String) throws -> Int
}

struct Operator<T> {
    let precedence: Int
    let associativity: Associativity
    let function: (T, T) -> T
    
}

enum Associativity {
    case left
    case right
}

struct AnyCalculator<T> {
    typealias Number = Int
    init(operators: Dictionary<String, Operator<Int>>) {
        fatalError("TODO: Implement")
    }
    func evaluate(_ input: String) throws -> Int {
        fatalError("TODO: Implement")
    }
}

typealias IntegerCalculator = AnyCalculator<Int>
typealias RealCalculator = AnyCalculator<Double>

func test(calculator type: (some Calculator<Int>).Type) {
    let calculator = type.init(operators: [
        "+": Operator(precedence: 10, associativity: .left, function: +),
        "-": Operator(precedence: 10, associativity: .left, function: -),
        "*": Operator(precedence: 20, associativity: .left, function: *),
        "/": Operator(precedence: 20, associativity: .left, function: /),
    ])
    
    let result1 = try! calculator.evaluate("2 + 2 * 2 + 2 / 2")
    print(result1)
    assert(result1 == 7)
}

