import CoreBluetooth

public class Characteristic: Identifiable {
    public var id: UUID
    public var characteristic: CBCharacteristic
    public var description: String
    public var uuid: CBUUID
    public var readValue: String
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
