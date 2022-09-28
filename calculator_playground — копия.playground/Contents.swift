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

