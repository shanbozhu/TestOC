//: [Previous](@previous)

//:* 计算属性可以用于类、结构体和枚举，存储属性只能用于类和结构体

//:**【存储属性】**
//:* 存储属性可以是变量存储属性（用关键字var定义），也可以是常量存储属性（用关键字let定义）
//:* 可以在定义存储属性的时候指定默认值，也可以在构造过程中设置或修改存储属性的值
//:* 所有结构体都有一个自动生成的成员逐一构造器，用于初始化新结构体实例中成员的属性
struct FixedLengthRange {
    var firstValue: Int
    let length: Int
}
var rangeOfThreeItems = FixedLengthRange(firstValue: 0, length: 3)
rangeOfThreeItems.firstValue = 6
//:* 延迟存储属性是指当第一次被调用的时候才会计算其初始值的属性，在属性声明前使用lazy来标示一个延迟存储属性，必须将延迟存储属性声明成变量，因为属性的初始值可能在实例构造完成之后才会得到，而常量属性在构造过程完成之前必须要有初始值，因此无法声明成延迟属性
class DataImporter {
    /*
     DataImporter是一个负责将外部文件中的数据导入的类，这个类的初始化会消耗不少时间
     */
    var fileName = "data.txt"
    // 这里会提供数据导入功能
}
class DataManager {
    lazy var importer = DataImporter()
    var data = [String]()
    // 这里会提供数据管理功能
}
let manager = DataManager()

//:**【计算属性】**
//:* 计算属性不直接存储值，而是提供一个getter和一个可选的setter，来间接获取和设置其他属性或变量的值，必须使用var关键字定义计算属性，因为它们的值不是固定的
struct Point {
    var x = 0.0, y = 0.0
}
struct Size {
    var width = 0.0, height = 0.0
}
struct Rect {
    var origin = Point()
    var size = Size()
    var center: Point {
        get {
            let centerX = origin.x + (size.width / 2)
            let centerY = origin.y + (size.height / 2)
            return Point(x: centerX, y: centerY)
        }
        set(newCenter) {
            origin.x = newCenter.x - (size.width / 2)
            origin.y = newCenter.y - (size.height / 2)
        }
    }
}
var square = Rect(origin: Point(x: 0.0, y: 0.0), size: Size(width: 10.0, height: 10.0))
square.center = Point(x: 15.0, y: 15.0)
print("square.origin is now at (\(square.origin.x), \(square.origin.y))")
//:* 如果计算属性的setter没有定义表示新值的参数名，则可以使用默认名称newValue
struct AlternativeRect {
    var origin = Point()
    var size = Size()
    var center: Point {
        get {
            let centerX = origin.x + (size.width / 2)
            let centerY = origin.y + (size.height / 2)
            return Point(x: centerX, y: centerY)
        }
        set {
            origin.x = newValue.x - (size.width / 2)
            origin.y = newValue.y - (size.height / 2)
        }
    }
}
//:* 只有getter没有setter的计算属性就是只读计算属性，只读计算属性的声明可以去掉get关键字和花括号
struct Cuboid {
    var width = 0.0, height = 0.0, depth = 0.0
    var volume: Double {
        return width * height * depth
    }
}

//:**【属性观察器】**
//:* 属性观察器监控和响应属性值的变化，每次属性被设置值的时候都会调用属性观察器，即使新值和当前值相同的时候也不例外
//:* 可以为除了延迟存储属性之外的其他存储属性添加属性观察器，也可以通过重写属性的方式为继承的属性（包括存储属性和计算属性）添加属性观察器
//:* willSet观察器会将新的属性值作为常量参数传入，在willSet的实现代码中可以为这个参数指定一个名称，如果不指定则使用默认名称newValue表示，didSet观察器会将旧的属性值作为参数传入，可以为该参数命名或者使用默认参数名oldValue
class StepCounter {
    var totalSteps: Int = 0 {
        willSet(newTotalSteps) {
            print("About to set totalSteps to \(newTotalSteps)")
        }
        didSet {
            if totalSteps > oldValue {
                print("Added \(totalSteps - oldValue) steps")
            }
        }
    }
}

//:**【类型属性】**
//:* 跟实例的存储型属性不同，必须给存储型类型属性指定默认值，因为类型本身没有构造器，也就无法在初始化过程中使用构造器给类型属性赋值
//:* 使用关键字static来定义类型属性，在为类定义计算型类型属性时，可以改用关键字class来支持子类对父类的实现进行重写
class SomeClass {
    static var storedTypeProperty = "Some value."
    static var computedTypeProperty: Int {
        return 27
    }
    class var overrideableComputedTypeProperty: Int {
        return 107
    }
}
//:* 类型属性是通过类型本身来访问，而不是通过实例
print(SomeClass.computedTypeProperty)

//: [Next](@next)
