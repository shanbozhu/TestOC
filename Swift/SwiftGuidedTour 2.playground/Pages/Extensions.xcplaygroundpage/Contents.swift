//: [Previous](@previous)

//:* 扩展就是为一个已有的类、结构体、枚举类型或者协议类型添加新功能，扩展可以为一个类型添加新的功能，但是不能重写已有的功能
//extension SomeType {
//    // 为 SomeType 添加的新功能写到这里
//}
//:* 扩展可以为已有类型添加计算型实例属性和计算型类型属性，但是不可以添加存储型属性，也不可以为已有属性添加属性观察器
extension Double {
    var km: Double { return self * 1_000.0 }
    var m : Double { return self }
    var cm: Double { return self / 100.0 }
    var mm: Double { return self / 1_000.0 }
    var ft: Double { return self / 3.28084 }
}
let oneInch = 25.4.mm
print("One inch is \(oneInch) meters")
let threeFeet = 3.ft
print("Three feet is \(threeFeet) meters")
//:* 扩展可以为已有类型添加新的构造器，扩展能为类添加新的便利构造器，但是它们不能为类添加新的指定构造器或析构器
struct Size {
    var width = 0.0, height = 0.0
}
struct Point {
    var x = 0.0, y = 0.0
}
struct Rect {
    var origin = Point()
    var size = Size()
}
extension Rect {
    init(center: Point, size: Size) {
        let originX = center.x - (size.width / 2)
        let originY = center.y - (size.height / 2)
        self.init(origin: Point(x: originX, y: originY), size: size)
    }
}
//:* 扩展可以为已有类型添加新的实例方法和类型方法
extension Int {
    func repetitions(task: () -> Void) {
        for _ in 0..<self {
            task()
        }
    }
}
3.repetitions(task: {
    print("Hello!")
})

//: [Next](@next)
