import SwiftUI
import CoreBluetooth

public enum ConnectionStatus {
    case connected
    case disconnected
    case searching
    case connecting
    case error
}

public class CoreBluetoothModule: NSObject, ObservableObject, CBPeripheralDelegate {
    @Published public var isBleOn: Bool = false
    @Published public var peripheralStatus: ConnectionStatus = .disconnected
    
    @Published public var discoverPeripherals: [Peripheral] = []
    @Published public var discoverCharacteristics: [Characteristic] = []
    @Published public var discoverServices: [Service] = []
    @Published public var connectedPeripheral: Peripheral!
    
    private var centralManager: CBCentralManager!
    
//    private let serviceUUID: CBUUID = CBUUID()
    
    override public init() {
        super.init()
        
        centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true])
    }
    
    private func resetConfiguration() {
        withAnimation {
            peripheralStatus = .disconnected
            discoverPeripherals = []
            discoverCharacteristics = []
            discoverServices = []
        }
    }
    
    //    MARK: Controling Functions
    public func startScan() {
        peripheralStatus = .searching
        let option = [CBCentralManagerScanOptionAllowDuplicatesKey: false]
        centralManager?.scanForPeripherals(withServices: nil, options: option)
        print("Scan Started...")
    }
    
    public func stopScan() {
        peripheralStatus = .disconnected
        disconnectPeripheral()
        centralManager?.stopScan()
        print("Scan Stoped!")
    }
    
    public func connectPeripheral(_ selectedPeripheral: Peripheral?) {
        guard let connectedPeripheral = selectedPeripheral else { return }
        self.connectedPeripheral = selectedPeripheral
        centralManager.connect(connectedPeripheral.peripheral, options: nil)
    }
    
    public func disconnectPeripheral() {
        guard let connectedPeripheral = connectedPeripheral else { return }
        centralManager.cancelPeripheralConnection(connectedPeripheral.peripheral)
    }
}

//MARK: CoreBluetooth CentralManager Delegete Functions
extension CoreBluetoothModule: CBCentralManagerDelegate {
    public func didDiscover(_ central: CBCentralManager, peripheral: CBPeripheral, advertisementData: [String : Any], rssi: NSNumber) {
        guard rssi.intValue < 0 else { return }
        
        let peripheralName = advertisementData[CBAdvertisementDataLocalNameKey] as? String ?? nil
        var _name = "No Name"
        
        if peripheralName != nil {
            _name = String(peripheralName!)
        } else if peripheral.name != nil {
            _name = String(peripheral.name!)
        }
        
        let discoveredPeripheral: Peripheral = Peripheral(
            _peripheral: peripheral,
            _name: _name,
            _advertisementData: advertisementData,
            _rssi: rssi,
            _discoverNumber: 0)
        
        if let index = discoverPeripherals.firstIndex(where: { $0.peripheral.identifier.uuidString == peripheral.identifier.uuidString }) {
            if discoverPeripherals[index].discoverNumber % 50 == 0 {
                discoverPeripherals[index].name = _name
                discoverPeripherals[index].rssi = rssi.intValue
                discoverPeripherals[index].discoverNumber += 1
            } else {
                discoverPeripherals[index].discoverNumber += 1
            }
        } else {
            discoverPeripherals.append(discoveredPeripheral)
            peripheralStatus = .connecting
        }
        
        print("Did discover \(peripheral.name ?? "No name")")
    }
    
    public func didUpdateState(_ central: CBCentralManager) {
        switch central.state {
           case .poweredOn:
               isBleOn = true
               startScan()
           case .poweredOff:
               isBleOn = false
               resetConfiguration() // Reset any ongoing scans or connections
               print("Bluetooth is powered off.")
           case .resetting:
               print("Bluetooth is resetting.")
           case .unauthorized:
               print("Bluetooth is unauthorized.")
           case .unknown:
               print("Bluetooth state is unknown.")
           case .unsupported:
               print("Bluetooth is unsupported.")
           @unknown default:
               print("Unknown Bluetooth state.")
           }
    }
    
    public func didConnect(_ center: CBCentralManager, peripheral: CBPeripheral) {
        guard let connectedPeripheral = connectedPeripheral else { return }
        peripheralStatus = .connected
        connectedPeripheral.peripheral.delegate = self
        connectedPeripheral.peripheral.discoverServices(nil)
        centralManager.stopScan()
        
        print("\(peripheral.name ?? "No name") is connected.")
    }
    
    public func didFailToConnect(_ central: CBCentralManager, peripheral: CBPeripheral, error: Error?) {
        if let error = error {
              print("Failed to connect to peripheral: \(error.localizedDescription)")
              
              if let cbError = error as? CBError {
                  switch cbError.code {
                  case .connectionFailed:
                      print("Peripheral connection failed.")
                  case .peripheralDisconnected:
                      print("Peripheral disconnected.")
                  default:
                      print("Unknown error: \(cbError)")
                  }
              }
          } else {
              print("Failed to connect to peripheral with unknown error.")
          }
          disconnectPeripheral()
          peripheralStatus = .error
          
          DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
              self.peripheralStatus = .disconnected
          }
    }
    
    public func didDisconnect(_ central: CBCentralManager, peripheral: CBPeripheral, error: Error?) {
        if let error = error {
            print("Disconnected from peripheral '\(peripheral.identifier.uuidString)' with error: \(error.localizedDescription)")
        } else {
            print("Disconnected from peripheral '\(peripheral.identifier.uuidString)'")
        }
        resetConfiguration()
        
        peripheralStatus = .disconnected
    }
    
    public func connectionEventDidOccur(_ central: CBCentralManager, event: CBConnectionEvent, peripheral: CBPeripheral) {
        
    }
    
    public func willRestoreState(_ central: CBCentralManager, dict: [String : Any]) {
        
    }
    
    public func didUpdateANCSAuthorization(_ central: CBCentralManager, peripheral: CBPeripheral) {
        
    }
    
    //MARK: CoreBluetooth Peripheral Delegate Functions
    public func didDiscoverServices(_ peripheral: CBPeripheral, error: Error?) {
        peripheral.services?.forEach { service in
            let foundService = Service(_uuid: service.uuid, _service: service)
            
            discoverServices.append(foundService)
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    public func didDiscoverCharacteristics(_ peripheral: CBPeripheral, service: CBService, error: Error?) {
        service.characteristics?.forEach { characteristic in
            let foundCharacteristic = Characteristic(
                _characteristic: characteristic,
                _description: "",
                _uuid: characteristic.uuid,
                _readValue: "",
                _service: characteristic.service!)
            
            discoverCharacteristics.append(foundCharacteristic)
            peripheral.readValue(for: characteristic)
        }
    }
    
    public func didUpdateValue(_ peripheral: CBPeripheral, characteristic: CBCharacteristic, error: Error?) {
        guard let characteristicValue = characteristic.value else { return }
        
        if let index = discoverCharacteristics.firstIndex(where: { $0.uuid.uuidString == characteristic.uuid.uuidString }) {
            
            discoverCharacteristics[index].readValue = characteristicValue.map({ String(format:"%02x", $0) }).joined()
        }
    }
    
    public func didWriteValue(_ peripheral: CBPeripheral, descriptor: CBDescriptor, error: Error?) {
        
    }
}
