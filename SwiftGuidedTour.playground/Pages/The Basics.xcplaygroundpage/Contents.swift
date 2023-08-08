//:**【Hello World】**
print("Hello, world!")

//:**【常量和变量】**
var completeVariable: Double = 42
//:* 常量和变量必须在使用前声明，用let来声明常量，用var来声明变量
var myVariable = 42
myVariable = 50
let myConstant = 42
//:* 如果在声明常量或者变量的时候赋了一个初始值，Swift可以推断出这个常量或者变量的类型
let implicitInteger = 70
let implicitDouble = 70.0
//:* 无法正确推断类型时需要显式声明类型
let explicitDouble: Double = 70
import CoreGraphics
let explicitCGFloat: CGFloat = 70

//:**【整型和浮点型】**
//:* Swift的整数类型：Int, Int8, Int16, Int32, Int64, UInt, UInt8, UInt16, UInt32, UInt64
//:* 在32位平台上，Int和Int32长度相同，UInt和UInt32长度相同，在64位平台上，Int和Int64长度相同，UInt和UInt64长度相同
//:* 统一使用Int可以提高代码的可复用性，避免不同类型数字之间的转换，并且匹配数字的类型推断
let meaningOfLife = 42  // Int
//:* Swift的浮点数类型Float, Double
let pi = 3.14159  // Double
//:* 如果数字超出了常量或变量可存储的范围，编译的时候会报错
//let cannotBeNegative: UInt8 = -1
//:* 不同类型的常量或变量不能直接进行运算
let twoThousand: UInt16 = 2000
let one: UInt8 = 1
let twoThousandAndOne = twoThousand + UInt16(one)
//:* 结合数字类常量和变量不同于结合数字类字面量，字面量3可以直接和字面量0.14159相加，因为数字字面量本身没有明确的类型，它们的类型只在编译器需要求值的时候被推测

//:**【布尔型】**
//:* Swift的布尔类型为Bool，两个布尔常量为true和false
let orangesAreOrange = true
let turnipsAreDelicious = false
//:* 如果你在需要使用Bool类型的地方使用了非布尔值，Swift的类型安全机制会报错
//let i = 1
//if i {
//    /* */
//}

//:**【元组】**
//:* 元组把多个值组合成一个复合值，元组内的值可以是任意类型，并不要求是相同类型
let http404Error = (404, "Not Found")  // 类型为(Int, String)
//:* 可以将一个元组的内容分解成单独的常量和变量
let (statusCode, statusMessage) = http404Error
let (justTheStatusCode, _) = http404Error
//:* 可以通过下标来访问元组中的单个元素，下标从零开始
print("The status code is \(http404Error.0)")
print("The status message is \(http404Error.1)")
//:* 可以在定义元组的时候给单个元素命名，并通过名字来获取这些元素的值
let http200Status = (statusCode: 200, description: "OK")
print("The status code is \(http200Status.statusCode)")
print("The status message is \(http200Status.description)")
//:* 元组在临时组织值的时候很有用，但是并不适合创建复杂的数据结构，如果你的数据结构并不是临时使用，请使用类或者结构体而不是元组

//:**【可选类型】**
//:* Swift使用可选类型来处理值可能缺失的情况，没有值时为nil
var serverResponseCode: Int? = 404
serverResponseCode = nil
//:* 如果声明一个可选常量或者变量但是没有赋值，它们会自动被设置为nil
var surveyAnswer: String?
//:* 当确定可选类型确实包含值之后，可以在可选的名字后面加一个感叹号!来获取值，这被称为可选值的强制解析
let possibleNumber = "123"
let convertedNumber = Int(possibleNumber)
if convertedNumber != nil {
    print("convertedNumber has an integer value of \(convertedNumber!).")
}
//:* 使用可选绑定来判断可选类型是否包含值，如果包含就把值赋给一个临时常量或者变量。可选绑定可以用在if和while语句中，这条语句不仅可以用来判断可选类型中是否有值，同时可以将可选类型中的值赋给一个常量或者变量
if let actualNumber = convertedNumber {
    print("\'\(possibleNumber)\' has an integer value of \(actualNumber)")
} else {
    print("\'\(possibleNumber)\' could not be converted to an integer")
}
//:* 可以在一个if语句中包含多个可选绑定或多个布尔条件，使用逗号分开，只要有任意一个可选绑定的值为nil，或者任意一个布尔条件为false，则整个if条件判断为false
if let firstNumber = Int("4"), let secondNumber = Int("42"), firstNumber < secondNumber && secondNumber < 100 {
    print("\(firstNumber) < \(secondNumber) < 100")
}
//:* 把想要用作可选的类型的后面的问号（String?）改成感叹号（String!）来声明一个隐式解析可选类型
let possibleString: String? = "An optional string."
let forcedString: String = possibleString!  // 需要感叹号来获取值
let assumedString: String! = "An implicitly unwrapped optional string."
let implicitString: String = assumedString  // 不需要感叹号
//:* 仍然可以把隐式解析可选类型当做普通可选类型来判断它是否包含值
if assumedString != nil {
    print(assumedString!)
}
//:* 仍然可以在可选绑定中使用隐式解析可选类型来检查并解析它的值
if let definiteString = assumedString {
    print(definiteString)
}

//: [Next](@next)
