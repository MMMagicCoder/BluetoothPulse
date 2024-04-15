import CoreBluetooth

/// Represents a Bluetooth characteristic.
public class Characteristic: Identifiable {
    /// The unique identifier of the characteristic.
    public var id: UUID
    
    /// The CoreBluetooth characteristic object.
    public var characteristic: CBCharacteristic
    
    /// A description of the characteristic.
    public var description: String
    
    /// The UUID of the characteristic.
    public var uuid: CBUUID
    
    /// The value read from the characteristic.
    public var readValue: String
    
    /// The service to which the characteristic belongs.
    public var service: CBService

    public init(_characteristic: CBCharacteristic,
         _description: String,
         _uuid: CBUUID,
         _readValue: String,
         _service: CBService) {
        
        id = UUID()
        characteristic = _characteristic
        description = _description == "" ? "NoName" : _description
        uuid = _uuid
        readValue = _readValue == "" ? "NoData" : _readValue
        service = _service
    }
}
