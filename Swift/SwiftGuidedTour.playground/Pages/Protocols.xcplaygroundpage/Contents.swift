//: [Previous](@previous)

//:**【协议语法】**
//:* 要让自定义类型遵循某个协议，在定义类型时，需要在类型名称后加上协议名称，中间以冒号（:）分隔，遵循多个协议时，各协议之间用逗号（ ,）分隔
//struct SomeStructure: FirstProtocol, AnotherProtocol {
//    // 这里是结构体的定义部分
//}
//:* 拥有父类的类在遵循协议时，应该将父类名放在协议名之前，以逗号分隔
//class SomeClass: SomeSuperClass, FirstProtocol, AnotherProtocol {
//    // 这里是类的定义部分
//}

//:**【属性要求】**
//:* 协议可以要求遵循协议的类型提供特定名称和类型的实例属性或类型属性，协议不指定属性是存储型属性还是计算型属性，此外，协议还指定属性是可读的还是可读可写的，如果协议要求属性是可读可写的，那么该属性不能是常量属性或只读的计算型属性，如果协议只要求属性是可读的，那么该属性不仅可以是可读的，如果代码需要的话，还可以是可写的，协议总是用var关键字来声明变量属性，在类型声明后加上{ set get }来表示属性是可读可写的，可读属性则用{ get }来表示
protocol SomeProtocol {
    var mustBeSettable: Int { get set }
    var doesNotNeedToBeSettable: Int { get }
}
//:* 在协议中定义类型属性时，总是使用static关键字作为前缀，当类类型遵循协议时，除了static关键字，还可以使用class关键字来声明类型属性
protocol AnotherProtocol {
    static var someTypeProperty: Int { get set }
}

//:**【方法要求】**
//:* 协议可以要求遵循协议的类型实现某些指定的实例方法或类方法，不支持为协议中的方法的参数提供默认值，正如属性要求中所述，在协议中定义类方法的时候，总是使用static关键字作为前缀，当类类型遵循协议时，除了static关键字，还可以使用class关键字作为前缀
protocol RandomNumberGenerator {
    func random() -> Double
}
//:* 如果在协议中定义了一个实例方法，该方法会改变遵循该协议的类型的实例，那么在定义协议时需要在方法前加mutating关键字，这使得结构体和枚举能够遵循此协议并满足此方法要求，实现协议中的mutating 方法时，若是类类型，则不用写mutating关键字，而对于结构体和枚举，则必须写mutating关键字
protocol Togglable {
    mutating func toggle()
}

//:**【协议作为类型】**
//:* 协议可以像其他普通类型一样使用，可以作为函数、方法或构造器中的参数类型或返回值类型，可以作为常量、变量或属性的类型，可以作为数组、字典或其他容器中的元素类型
class Dice {
    let sides: Int
    let generator: RandomNumberGenerator
    init(sides: Int, generator: RandomNumberGenerator) {
        self.sides = sides
        self.generator = generator
    }
    func roll() -> Int {
        return Int(generator.random() * Double(sides)) + 1
    }
}

//:**【通过扩展遵循协议】**
//:* 可以通过扩展令已有类型遵循并符合协议，和在原始定义中遵循并符合协议的效果完全相同
protocol TextRepresentable {
    var textualDescription: String { get }
}
extension Dice: TextRepresentable {
    var textualDescription: String {
        return "A \(sides)-sided dice"
    }
}
//:* 当一个类型已经符合了某个协议中的所有要求，却还没有声明遵循该协议时，可以通过空扩展体的扩展来遵循该协议，即使满足了协议的所有要求，类型也不会自动遵循协议，必须显式地遵循协议
struct Hamster {
    var name: String
    var textualDescription: String {
        return "A hamster named \(name)"
    }
}
extension Hamster: TextRepresentable {}

//:**【协议的继承】**
//:* 协议能够继承一个或多个其他协议，可以在继承的协议的基础上增加新的要求，协议的继承语法与类的继承相似，多个被继承的协议间用逗号分隔
protocol PrettyTextRepresentable: TextRepresentable {
    var prettyTextualDescription: String { get }
}

//:**【协议的合成】**
//:* 有时候需要同时遵循多个协议，可以将多个协议采用SomeProtocol & AnotherProtocol这样的格式进行组合，称为协议合成，可以罗列任意多个想要遵循的协议，以与符号(&)分隔
protocol Named {
    var name: String { get }
}
protocol Aged {
    var age: Int { get }
}
struct Person: Named, Aged {
    var name: String
    var age: Int
}
func wishHappyBirthday(to celebrator: Named & Aged) {
    print("Happy birthday, \(celebrator.name), you're \(celebrator.age)!")
}
let birthdayPerson = Person(name: "Malcolm", age: 21)
wishHappyBirthday(to: birthdayPerson)

//:**【可选协议】**
//:* 协议可以定义可选要求，遵循协议的类型可以选择是否实现这些要求，在协议中使用optional关键字作为前缀来定义可选要求，可选要求用在你需要和Objective-C打交道的代码中，协议和可选要求都必须带上@objc属性，标记@objc特性的协议只能被继承自Objective-C类的类或者@objc类遵循，其他类以及结构体和枚举均不能遵循这种协议
//:* 使用可选要求时（例如，可选的方法或者属性），它们的类型会自动变成可选的
import Foundation
@objc protocol CounterDataSource {
    @objc optional func incrementForCount(count: Int) -> Int
    @objc optional var fixedIncrement: Int { get }
}
class Counter {
    var count = 0
    var dataSource: CounterDataSource?
    func increment() {
        if let amount = dataSource?.incrementForCount?(count: count) {
            count += amount
        } else if let amount = dataSource?.fixedIncrement {
            count += amount
        }
    }
}

//:**【协议扩展】**
//:* 可以通过协议扩展来为协议要求的属性、方法提供默认的实现，如果遵循协议的类型为这些要求提供了自己的实现，那么这些自定义实现将会替代扩展中的默认实现被使用
extension PrettyTextRepresentable {
    var prettyTextualDescription: String {
        return textualDescription
    }
}

//: [Next](@next)
