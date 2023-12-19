//: [Previous](@previous)

//:**【函数定义与调用】**
func greet(person: String) -> String {
    let greeting = "Hello, " + person + "!"
    return greeting
}
print(greet(person: "Anna"))

func greetAgain(person: String) -> String {
    return "Hello again, " + person + "!"
}
print(greetAgain(person: "Anna"))

//:**【函数参数与返回值】**
// 无参数
func sayHelloWorld() -> String {
    return "hello, world"
}
print(sayHelloWorld())
// 多参数
func greet(person: String, alreadyGreeted: Bool) -> String {
    if alreadyGreeted {
        return greetAgain(person: person)
    } else {
        return greet(person: person)
    }
}
print(greet(person: "Tim", alreadyGreeted: true))
// 无返回值
func greetPrint(person: String) {
    print("Hello, \(person)!")
}
greetPrint(person: "Dave")
// 多返回值
func minMax(array: [Int]) -> (min: Int, max: Int) {
    var currentMin = array[0]
    var currentMax = array[0]
    for value in array[1..<array.count] {
        if value < currentMin {
            currentMin = value
        } else if value > currentMax {
            currentMax = value
        }
    }
    return (currentMin, currentMax)
}
let bounds = minMax(array: [8, -6, 2, 109, 3, 71])
print("min is \(bounds.min) and max is \(bounds.max)")

//:**【参数标签与参数名称】**
//:* 每个函数参数都有一个参数标签以及一个参数名称。参数标签在调用函数的时候使用，调用的时候需要将函数的参数标签写在对应的参数前面，参数名称在函数的实现中使用，默认情况下，函数参数使用参数名称来作为它们的参数标签
func greet(person: String, from hometown: String) -> String {
    return "Hello \(person)! Glad you could visit from \(hometown)."
}
print(greet(person: "Bill", from: "Cupertino"))
//:* 如果不希望为某个参数添加一个标签，可以使用一个下划线(_)来代替一个明确的参数标签
func someFunction(_ firstParameterName: Int, secondParameterName: Int) {
    // 在函数体内，firstParameterName和secondParameterName代表参数中的第一个和第二个参数值
}
someFunction(1, secondParameterName: 2)

//:**【参数默认值】**
//:* 可以在函数体中通过给参数赋值来为任意一个参数定义默认值，当默认值被定义后，调用这个函数时可以忽略这个参数，通常将带有默认值的参数放在函数参数列表的最后
func someFunction(parameterWithoutDefault: Int, parameterWithDefault: Int = 12) {
    // 如果你在调用时候不传第二个参数，parameterWithDefault会值为12传入到函数体中。
}
someFunction(parameterWithoutDefault: 3, parameterWithDefault: 6)  // parameterWithDefault = 6
someFunction(parameterWithoutDefault: 4)  // parameterWithDefault = 12

//:**【函数类型】**
//:* 函数的类型由函数的参数类型和返回类型组成
// 函数类型 (Int, Int) -> Int
func addTwoInts(_ a: Int, _ b: Int) -> Int {
    return a + b
}
// 函数类型 () -> Void
func printHelloWorld() {
    print("hello, world")
}
//:* 可以使用函数类型作为函数的参数类型
func printMathResult(_ mathFunction: (Int, Int) -> Int, _ a: Int, _ b: Int) {
    print("Result: \(mathFunction(a, b))")
}
printMathResult(addTwoInts, 3, 5)
//:* 可以使用函数类型作为函数的返回类型
func stepForward(_ input: Int) -> Int {
    return input + 1
}
func stepBackward(_ input: Int) -> Int {
    return input - 1
}
func chooseStepFunction(backward: Bool) -> (Int) -> Int {
    return backward ? stepBackward : stepForward
}

//: [Next](@next)
