//: [Previous](@previous)

//:**【枚举语法】**
enum CompassPoint {
    case north
    case south
    case east
    case west
}
var directionToHead = CompassPoint.west
directionToHead = .east
//:* 与C和Objective-C不同，Swift的枚举成员在被创建时不会被赋予一个默认的整型值，这些枚举成员本身就是完备的值

//:**【关联值】**
//:* 可以定义Swift枚举来存储任意类型的关联值，每个枚举成员的关联值类型可以各不相同
enum Barcode {
    case upc(Int, Int, Int, Int)
    case qrCode(String)
}
var productBarcode = Barcode.upc(8, 85909, 51226, 3)
productBarcode = .qrCode("ABCDEFGHIJKLMNOP")
//:* 可以使用一个switch语句来检查不同的枚举值，关联值可以被提取出来作为switch语句的一部分，可以在switch的case分支代码中提取每个关联值作为一个常量（用let前缀）或者作为一个变量（用var前缀）来使用
switch productBarcode {
    case .upc(let numberSystem, let manufacturer, let product, let check):
        print("UPC: \(numberSystem), \(manufacturer), \(product), \(check).")
    case .qrCode(let productCode):
        print("QR code: \(productCode).")
}

//:**【原始值】**
//:* 枚举成员可以有对应的原始值，原始值的类型必须相同，原始值可以是字符串、字符、任意整型值或浮点型值，每个原始值在枚举声明中必须是唯一的
enum ASCIIControlCharacter: Character {
    case tab = "\t"
    case lineFeed = "\n"
    case carriageReturn = "\r"
}
//:* 当使用整数作为原始值时，不需要显式地为每一个枚举成员设置原始值，隐式赋值的值依次递增1，如果第一个枚举成员没有设置原始值，其原始值将为0
enum Planet: Int {
    case mercury = 1, venus, earth, mars, jupiter, saturn, uranus, neptune
}
//:* 当使用字符串作为枚举类型的原始值时，每个枚举成员的隐式原始值为该枚举成员的名称
enum CompassPointEnum: String {
    case north, south, east, west
}
//:* 使用枚举成员的rawValue属性可以访问该枚举成员的原始值
let earthsOrder = Planet.earth.rawValue
let sunsetDirection = CompassPointEnum.west.rawValue
//:* 如果在定义枚举类型的时候使用了原始值，那么将会自动获得一个初始化方法，这个方法接收一个叫做rawValue的参数，参数类型即为原始值类型，返回值则是枚举成员或nil
let possiblePlanet = Planet(rawValue: 7)  // 类型为Planet?

//: [Next](@next)
