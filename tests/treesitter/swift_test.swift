import Foundation

protocol SomeProtocol {
    var someVar: String { get }

    func somess<T, V>(_ sss: T, xxx: V) -> V?
}
protocol SomeProtocol<T>: Encodable, Decodable where T == Element {}

enum SomeEnum {
    static var textures: [String: MTLTexture] = [:]

    func enumMethod<T, V>(_ sss: T, xxx: V) -> V? {
        return nil
    }

    var computedProperty: String {
        // xxx
        ""
    }
}

public class SomeClass: Codable {
    var somesss = 0
    let another = 111
    var sieee: Int = 11
    var computedProperty: String {
        // xxx
        ""
    }
    func some(zzz: String, xxx: Int) {}
    public func some(sommm: Int, _ another: String) {

    }

    public func somess<T, V>(_ sss: T, xxx: V) -> V? {}
    public func somess<T, V>(_ sss: T, xxx: V) -> V {}
    func some(_ completion: @escaping ((String) -> Void)) {
    }
    func anotherFucn() -> (String, Int) {}
    func anotherFucn() -> [String: Int] {}
    func anotherFucxn() -> [String] {}
    func anotherFucn() -> Set<String> {}
    func anotherFucn() -> [String] {}
    func anotherFucn() async -> [String] {}
    func anotherFucn() throws -> [String] {}
    func anotherFucn() async throws -> [String] {}
}

func someExternalFunc() {}

extension SomeProtocol: Encodable, Decodable {}

actor SomeActor {
    var goodVar = 11
    func somssssse() {}
    func some(x: Int, _ y: String) -> String? {
        var wrongVar = 111
    }

    func llll() -> String { "" }
    init(_ vars: String) {}
    deinit {}
}

class SomeClass<T, V>: Codable where T: Decodable, V: Encodable {
    struct SomeAnother {
        init() {

        }
    }
    init<T, V>(_ sss: T, xxx: V) {

    }
}

struct SomeAAA {
    struct SomeBBBB {
        let ppppp: Int?
    }
    enum Some {
        case some
    }
    var xxxx: String?
}

extension SomeAAA.SomeBBBB { // breaks breadcrumbs
    var someVariable: String { "" }
}

var toplevelVariable: String = "hello"

var globalComputedProperty: String {
    "xxx"
}
