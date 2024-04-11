import SwiftUI
import CoreBluetooth

public class CoreBluetoothModule: NSObject, ObservableObject, CBPeripheralDelegate, CBCentralManagerDelegate {
    @Published var isBleOn: Bool = false
    @Published var isSearching: Bool = false
    @Published var isConnected: Bool = false
    
    @Published var discoverPeripherals: [Peripheral] = []
    @Published var discoverCharacteristics: [Characteristic] = []
    @Published var discoverServices: [Service] = []
    @Published var connectedPeripheral: Peripheral!
    
    private var centralManager: CBCentralManager!
    
    private let serviceUUID: CBUUID = CBUUID()
    
    override init() {
        super.init()
        
        centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true])
    }
    
    private func resetConfiguration() {
        withAnimation {
            isSearching = false
            isConnected = false
            
            discoverPeripherals = []
            discoverCharacteristics = []
            discoverServices = []
        }
    }
    
    //    MARK: Controling Functions
    public func startScan() {
        let option = [CBCentralManagerScanOptionAllowDuplicatesKey: false]
        centralManager?.scanForPeripherals(withServices: nil, options: option)
        print("Scan Started...")
        isSearching = true
    }
    
    public func stopScan() {
        disconnectPeripheral()
        centralManager?.stopScan()
        print("Scan Stoped!")
        isSearching = false
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
    
    //MARK: CoreBluetooth CentralManager Delegete Functions
    public func didUpdateState(_ central: CBCentralManager) {
        guard central.state == .poweredOn else { return isBleOn = false}
        isBleOn = true
        startScan()
    }
    
    public func didDiscover(_ central: CBCentralManager, peripheral: CBPeripheral, advertisementData: [String : Any], rssi: NSNumber) {
        guard rssi.intValue < 0 else { return }
        
        let peripheralName = advertisementData[CBAdvertisementDataLocalNameKey] as? String ?? nil
        var _name = "NoName"
        
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
            self.isSearching = false
        }
    }
    
    public func didConnect(_ center: CBCentralManager, peripheral: CBPeripheral) {
        guard let connectedPeripheral = connectedPeripheral else { return }
        self.isConnected = true
        connectedPeripheral.peripheral.delegate = self
        connectedPeripheral.peripheral.discoverServices(nil)
    }
    
    public func didFailToConnect(_ central: CBCentralManager, peripheral: CBPeripheral, error: Error?) {
        if let error = error {
            print("Failed to connect to peripheral: \(error.localizedDescription)")
        } else {
            print("Failed to connect to peripheral with unknown error.")
        }
        disconnectPeripheral()
    }
    
    public func didDisconnect(_ central: CBCentralManager, peripheral: CBPeripheral, error: Error?) {
        if let error = error {
            print("Disconnected from peripheral '\(peripheral.identifier.uuidString)' with error: \(error.localizedDescription)")
        } else {
            print("Disconnected from peripheral '\(peripheral.identifier.uuidString)'")
        }
        resetConfiguration()
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
