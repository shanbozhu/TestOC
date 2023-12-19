//: [Previous](@previous)

//:* 类、结构体、枚举都可以定义实例方法和类型方法

//:**【实例方法】**
class Counter {
    var count = 0
    func increment() {
        count += 1
    }
    func increment(by amount: Int) {
        count += amount
    }
    func reset() {
        count = 0
    }
}
let counter = Counter()
counter.increment()
counter.increment(by: 5)
counter.reset()
//:* 类型的每一个实例都有一个隐含属性叫做self，可以在一个实例的实例方法中使用这个隐含的self属性来引用当前实例，使用这条规则的主要场景是实例方法的某个参数名称与实例的某个属性名称相同的时候，在这种情况下，参数名称享有优先权，可以使用self属性来区分参数名称和属性名称
//:* 结构体和枚举是值类型，默认情况下，值类型的属性不能在它的实例方法中被修改，但是，如果确实需要在某个特定的方法中修改结构体或者枚举的属性，可以将关键字mutating放到方法的func关键字之前将这个方法声明为可变方法
struct Point {
    var x = 0.0, y = 0.0
    mutating func moveByX(x deltaX: Double, y deltaY: Double) {
        x += deltaX
        y += deltaY
    }
}
var somePoint = Point(x: 1.0, y: 1.0)
somePoint.moveByX(x:2.0, y: 3.0)
print("The point is now at (\(somePoint.x), \(somePoint.y))")
//:* 不能在结构体类型的常量上调用可变方法，因为其属性不能被改变，即使属性是变量属性
//let fixedPoint = Point(x: 3.0, y: 3.0)
//fixedPoint.moveByX(2.0, y: 3.0)

//:**【类型方法】**
//:* 在方法的func关键字之前加上关键字static来指定类型方法，类还可以用关键字class来允许子类重写父类的方法实现
class SomeClass {
    class func someTypeMethod() {
        // 在这里实现类型方法
    }
}
//:* 类型方法和实例方法一样用点语法调用，但是，是在类型上调用这个方法，而不是在实例上调用
SomeClass.someTypeMethod()
//:* 在类型方法的方法体中，self指向这个类型本身，而不是类型的某个实例

//: [Next](@next)
