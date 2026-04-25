//: [Previous](@previous)

//:* 构造过程是使用类、结构体或枚举类型的实例之前的准备过程，在新实例可用前必须执行这个过程，具体操作包括设置实例中每个存储型属性的初始值和执行其他必须的设置或初始化工作

//:**【存储属性的初始赋值】**
//:* 类和结构体在创建实例时，必须为所有存储型属性设置合适的初始值，可以在构造器中为存储型属性赋初值，也可以在定义属性时为其设置默认值，当为存储型属性设置默认值或者在构造器中为其赋值时，它们的值是被直接设置的，不会触发任何属性观察者

//:**【自定义构造过程】**
//:* 构造方法以关键字init命名，没有返回值
struct Celsius {
    let temperatureInCelsius: Double
    init(fromFahrenheit fahrenheit: Double) {
        temperatureInCelsius = (fahrenheit - 32.0) / 1.8
    }
    init(fromKelvin kelvin: Double) {
        temperatureInCelsius = kelvin - 273.15
    }
}
let boilingPointOfWater = Celsius(fromFahrenheit: 212.0)
let freezingPointOfWater = Celsius(fromKelvin: 273.15)

//:**【默认构造器】**
//:* 如果结构体或类的所有属性都有默认值，同时没有自定义的构造器，那么Swift会给这些结构体或类提供一个默认构造器，这个默认构造器将简单地创建一个所有属性值都设置为默认值的实例
class ShoppingListItem {
    var name: String?
    var quantity = 1
    var purchased = false
}
var item = ShoppingListItem()
//:* 除了上面提到的默认构造器，如果结构体没有提供自定义的构造器，它们将自动获得一个逐一成员构造器，即使结构体的存储型属性没有默认值

//:**【类的继承和构造过程】**
//:* 指定构造器是类中最主要的构造器，每一个类都必须拥有至少一个指定构造器
//init(parameters) {
//    statements
//}
//:* 便利构造器是类中比较次要的、辅助型的构造器
//convenience init(parameters) {
//    statements
//}
//: 1) 指定构造器必须调用其直接父类的的指定构造器
//: 2) 便利构造器必须调用同类中定义的其它构造器
//: 3) 便利构造器必须最终导致一个指定构造器被调用

//:**【构造器的继承和重写】**
//:* 跟Objective-C中的子类不同，Swift中的子类默认情况下不会继承父类的构造器
//:* 当编写一个和父类中指定构造器相匹配的子类构造器时，必须在定义子类构造器时带上override修饰符，即使重写的是系统自动提供的默认构造器，即使子类将父类的指定构造器重写为了便利构造器，重写父类便利构造器时，不需要加override前缀
//:* 假设子类中引入的所有新属性都提供了默认值，以下两个规则适用：
//: 规则 1：如果子类没有定义任何指定构造器，它将自动继承所有父类的指定构造器
//: 规则 2：如果子类提供了所有父类指定构造器的实现——无论是通过规则1继承过来的，还是提供了自定义实现——它将自动继承所有父类的便利构造器

//:**【可失败构造器】**
//:* 如果一个类、结构体或枚举类型的对象，在构造过程中有可能失败，则为其定义一个可失败构造器，这里所指的“失败”是指，如给构造器传入无效的参数值，或缺少某种所需的外部资源，又或是不满足某种必要的条件等，其语法为在init关键字后面添加问号(init?)
//:* 可失败构造器会创建一个类型为自身类型的可选类型的对象，通过return nil语句来表明可失败构造器在何种情况下应该“失败”
struct Animal {
    let species: String
    init?(species: String) {
        if species.isEmpty { return nil }
        self.species = species
    }
}
let someCreature = Animal(species: "Giraffe")  // Animal?
if let giraffe = someCreature {
    print("An animal was initialized with a species of \(giraffe.species)")
}

//:**【必要构造器】**
//:* 在类的构造器前添加required修饰符表明所有该类的子类都必须实现该构造器，在子类重写父类的必要构造器时，必须在子类的构造器前也添加required修饰符，表明该构造器要求也应用于继承链后面的子类，在重写父类中必要的指定构造器时，不需要添加override修饰符
class SomeClass {
    required init() {
        // 构造器的实现代码
    }
}
class SomeSubclass: SomeClass {
    required init() {
        // 构造器的实现代码
    }
}

//: [Next](@next)
