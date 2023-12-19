//: [Previous](@previous)

//:**【闭包表达式语法】**
//{ (parameters) -> returnType in
//    statements
//}
let closure: (String, String) -> Bool = { (s1: String, s2: String) -> Bool in
    return s1 > s2
}
closure("Chris", "Alex")

let names = ["Chris", "Alex", "Ewa", "Barry", "Daniella"]
var reversedNames = names.sorted(by: { (s1: String, s2: String) -> Bool in
    return s1 > s2
})
//:* Swift可以推断闭包的参数和返回值的类型
reversedNames = names.sorted(by: { s1, s2 in return s1 > s2 } )
//:* 单行表达式闭包可以通过省略return关键字来隐式返回单行表达式的结果
reversedNames = names.sorted(by: { s1, s2 in s1 > s2 } )
//:* Swift自动为内联闭包提供了参数名称缩写功能，可以直接通过$0、 $1、 $2来顺序调用闭包的参数，以此类推
reversedNames = names.sorted(by: { $0 > $1 } )

//:**【尾随闭包】**
//:* 如果需要将一个很长的闭包表达式作为最后一个参数传递给函数，可以使用尾随闭包来增强函数的可读性，尾随闭包是一个书写在函数括号之后的闭包表达式，函数支持将其作为最后一个参数调用，在使用尾随闭包时，不用写出它的参数标签
reversedNames = names.sorted() { $0 > $1 }
//:* 如果闭包表达式是函数或方法的唯一参数，使用尾随闭包时，可以把()省略掉
reversedNames = names.sorted { $0 > $1 }

//:**【值捕获】**
//:* 闭包可以在其被定义的上下文中捕获常量或变量，即使定义这些常量和变量的原作用域已经不存在，闭包仍然可以在闭包函数体内引用和修改这些值。
func makeIncrementer(forIncrement amount: Int) -> () -> Int {
    var runningTotal = 0
    let incrementer = {() -> Int in
        runningTotal += amount
        return runningTotal
    }
    return incrementer
}
let incrementByTen = makeIncrementer(forIncrement: 10)
incrementByTen()
incrementByTen()
incrementByTen()

//: [Next](@next)
