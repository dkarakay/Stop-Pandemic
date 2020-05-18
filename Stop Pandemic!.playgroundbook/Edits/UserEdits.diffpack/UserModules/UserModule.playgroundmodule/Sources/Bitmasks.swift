// For detecting collisions easier
public struct Bitmasks{
    static let player: UInt32 = 1 << 1
    static let enemy: UInt32 = 1 << 2
    static let invisible: UInt32 = 1 << 3
    static let aid: UInt32 = 1 << 4
    static let world: UInt32 = 1 << 5
}

