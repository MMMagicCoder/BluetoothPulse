import CoreBluetooth

public class Service: Identifiable {
    public var id: UUID
    public var uuid: CBUUID
    public var service: CBService

    public init(_uuid: CBUUID,
         _service: CBService) {
        
        id = UUID()
        uuid = _uuid
        service = _service
    }
}

