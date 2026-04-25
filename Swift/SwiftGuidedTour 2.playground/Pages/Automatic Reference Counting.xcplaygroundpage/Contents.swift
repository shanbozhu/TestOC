//: [Previous](@previous)

//:**【弱引用】**
//:* 弱引用阻止了引用变为循环强引用，声明属性或者变量时，在前面加上weak关键字表明这是一个弱引用，弱引用的实例被销毁后会自动赋值为nil，所以弱引用变量必须被定义为可选类型变量
class Person {
    let name: String
    init(name: String) { self.name = name }
    var apartment: Apartment?
    deinit { print("\(name) is being deinitialized") }
}
class Apartment {
    let unit: String
    init(unit: String) { self.unit = unit }
    weak var tenant: Person?
    deinit { print("Apartment \(unit) is being deinitialized") }
}
//:* 闭包中使用捕获列表解决循环强引用问题，捕获列表中的每一项都由一对元素组成，一个元素是weak关键字，另一个元素是类实例的引用（例如self）或初始化过的变量（如delegate = self.delegate!），这些项在方括号中用逗号分开
//var someClosure: (Int, String) -> String = {
//    [weak self, weak delegate = self.delegate!] (index: Int, stringToProcess: String) -> String in
//    // 这里是闭包的函数体
//}

//: [Next](@next)
