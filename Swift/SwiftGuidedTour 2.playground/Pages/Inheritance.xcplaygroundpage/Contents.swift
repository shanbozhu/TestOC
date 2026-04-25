//: [Previous](@previous)

//:**【子类生成】**
//:* 为了指明某个类的基类，将基类名写在子类名的后面，用冒号分隔
class Vehicle {
    var currentSpeed = 0.0
    var description: String {
        return "traveling at \(currentSpeed) miles per hour"
    }
    func makeNoise() {
    }
}
class Bicycle: Vehicle {
    var hasBasket = false
}

//:**【重写】**
//:* 子类可以重写继承来的实例方法、类方法、实例属性，如果要重写某个特性，需要在重写定义的前面加上override关键字
//:* 在方法someMethod()的重写实现中，可以通过super.someMethod()来调用基类版本的someMethod()方法，在属性someProperty的getter或setter的重写实现中，可以通过super.someProperty来访问基类版本的someProperty属性
class Train: Vehicle {
    override func makeNoise() {
        print("Choo Choo")
    }
}
//:* 可以提供定制的getter（或setter）来重写任意继承来的属性，无论继承来的属性是存储型的还是计算型的属性
//:* 可以将一个继承来的只读属性重写为一个读写属性，只需要在重写版本的属性里提供getter和setter即可，但是不可以将一个继承来的读写属性重写为一个只读属性
class Car: Vehicle {
    var gear = 1
    override var description: String {
        return super.description + " in gear \(gear)"
    }
}

//:**【防止重写】**
//:* 可以通过把方法或属性标记为final来防止它们被重写，只需要在声明关键字前加上final修饰符即可（例如final var、 final func）
//:* 可以通过在关键字class前添加final修饰符（final class）来将整个类标记为final的，这样的类是不可被继承的

//: [Next](@next)
