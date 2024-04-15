import CoreBluetooth

/// Represents a Bluetooth peripheral device.
public class Peripheral: Identifiable, Equatable {
    
    /// Compares two Peripheral instances for equality.
    /// - Parameters:
    ///   - lhs: The left-hand side Peripheral.
    ///   - rhs: The right-hand side Peripheral.
    /// - Returns: True if the peripherals are equal, otherwise false.
    public static func == (lhs: Peripheral, rhs: Peripheral) -> Bool {
        return lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        NSDictionary(dictionary: lhs.advertisementData).isEqual(to: rhs.advertisementData) &&
        lhs.rssi == rhs.rssi
    }
    
    /// The unique identifier of the peripheral.
    public var id: UUID
    
    /// The CoreBluetooth peripheral object.
    public var peripheral: CBPeripheral
    
    /// The name of the peripheral.
    public var name: String
    
    /// The advertisement data of the peripheral.
    public var advertisementData: [String: Any]
    
    /// The received signal strength indicator (RSSI) of the peripheral.
    public var rssi: Int
    
    /// The number of times this peripheral has been discovered.
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
