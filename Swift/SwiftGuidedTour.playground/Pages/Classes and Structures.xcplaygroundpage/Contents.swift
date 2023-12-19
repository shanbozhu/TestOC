//: [Previous](@previous)

//:**【类和结构体对比】**
//:* 通过关键字class和struct来分别表示类和结构体，并在一对大括号中定义它们的具体内容
struct Resolution {
    var width = 0
    var height = 0
}
class VideoMode {
    var resolution = Resolution()
    var interlaced = false
    var frameRate = 0.0
    var name: String?
}
let someResolution = Resolution()
let someVideoMode = VideoMode()
//:* 类和结构体的共同点：
//: 1) 定义属性用于存储值
//: 2) 定义方法用于提供功能
//: 3) 定义构造器用于生成初始化值
//: 4) 通过扩展以增加默认实现的功能
//: 5) 实现协议以提供某种标准功能
//:* 类和结构体的不同点：
//: 1) 类是引用类型，结构体是值类型
//: 2) 继承允许一个类继承另一个类的特征
//: 3) 类型转换允许在运行时检查和解释一个类实例的类型
//: 4) 析构器允许一个类实例释放任何其所被分配的资源
//:* 通过使用点语法，可以访问实例的属性
print("The width of someResolution is \(someResolution.width)")
print("The width of someVideoMode is \(someVideoMode.resolution.width)")

//:**【值类型和引用类型】**
//:* 值类型被赋予给一个变量、常量或者被传递给一个函数的时候，其值会被拷贝，在Swift中，所有的基本类型：整数、浮点数、布尔值、字符串、数组和字典，都是值类型，并且在底层都是以结构体的形式所实现。在Swift中，所有的结构体和枚举类型都是值类型
//:* 引用类型在被赋予到一个变量、常量或者被传递到一个函数时，其值不会被拷贝，引用的是已存在的实例本身而不是其拷贝
let tenEighty = VideoMode()
tenEighty.frameRate = 25.0
let alsoTenEighty = tenEighty
alsoTenEighty.frameRate = 30.0
print("The frameRate property of tenEighty is now \(tenEighty.frameRate)")
//:* 可以使用等价于（===）和不等价于（!==）运算符检测两个常量或者变量是否引用同一个实例
if tenEighty === alsoTenEighty {
    print("tenEighty and alsoTenEighty refer to the same Resolution instance.")
}
//:* Objective-C中NSString、 NSArray和NSDictionary类型均以类的形式实现，而并非结构体，它们在被赋值或者被传入函数或方法时，不会发生值拷贝，而是传递现有实例的引用

//: [Next](@next)
