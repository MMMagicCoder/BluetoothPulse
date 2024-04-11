import CoreBluetooth

public class Peripheral: Identifiable, Equatable {
    public static func == (lhs: Peripheral, rhs: Peripheral) -> Bool {
        lhs.id == rhs.id && lhs.name == rhs.name
    }
    
    public var id: UUID
    public var peripheral: CBPeripheral
    public var name: String
    public var advertisementData: [String: Any]
    public var rssi: Int
    public var discoverNumber: Int
    
    public init(_peripheral: CBPeripheral, _name: String, _advertisementData: [String : Any], _rssi: NSNumber, _discoverNumber: Int) {
        id = UUID()
        peripheral = _peripheral
        name = _name
        advertisementData = _advertisementData
        rssi = _rssi.intValue
        discoverNumber = _discoverNumber
    }
}
