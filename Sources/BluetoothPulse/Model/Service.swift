import CoreBluetooth

/// Represents a Bluetooth service.
public class Service: Identifiable {
    
    /// The unique identifier of the service.
    public var id: UUID
    
    /// The UUID of the service.
    public var uuid: CBUUID
    
    /// The CoreBluetooth service object.
    public var service: CBService

    public init(_uuid: CBUUID,
         _service: CBService) {
        
        id = UUID()
        uuid = _uuid
        service = _service
    }
}

