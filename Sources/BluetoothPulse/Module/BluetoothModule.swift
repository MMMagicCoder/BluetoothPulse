import SwiftUI
import CoreBluetooth

/**
 Enum representing different Bluetooth connection statuses.
 
 Use this enum to track the status of a Bluetooth connection within your SwiftUI app. It provides a clear and concise way to handle different states of Bluetooth connectivity.
 
 - `connected`: Indicates that the device is currently connected to a Bluetooth peripheral.
 - `connecting`: Indicates that the device is in the process of establishing a connection to a Bluetooth peripheral.
 - `disconnected`: Indicates that the device is not connected to any Bluetooth peripheral.
 - `searching`: Indicates that the device is searching for nearby Bluetooth peripherals.
 - `error`: Indicates that an error occurred while attempting to establish or maintain a Bluetooth connection.
 */
public enum ConnectionStatus {
    case connected
    case disconnected
    case searching
    case connecting
    case error
}

public class BluetoothModule: NSObject, ObservableObject, CBPeripheralDelegate {
    @Published public var isBleOn: Bool = false
    @Published public var peripheralStatus: ConnectionStatus = .disconnected
    
    /**
     A published property containing UUIDs of services to be scanned for.
     
     Use this property to specify the UUIDs of the services you want to scan for when searching for nearby peripherals in your SwiftUI app. You can customize it by adding custom CBUUIDs representing the services your app is interested in.
     */
    @Published public var serviceUUIDs: [CBUUID]? = nil
    /**
     A published property containing all discovered peripherals.
     */
    @Published public var discoverPeripherals: [Peripheral] = []
    /**
     A published property containing all discovered characteristics.
     */
    @Published public var discoverCharacteristics: [Characteristic] = []
    /**
     A published property containing all discovered services.
     */
    @Published public var discoverServices: [Service] = []
    /**
     A published property representing currently connected peripheral.
     */
    @Published public var connectedPeripheral: Peripheral!
    
    private var centralManager: CBCentralManager!
    
    override public init() {
        super.init()
        
        centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true])
    }
    
    /// Reset configuration and stop ongoing scans or connections.
    private func resetConfiguration() {
        withAnimation {
            peripheralStatus = .disconnected
            discoverPeripherals = []
            discoverCharacteristics = []
            discoverServices = []
        }
    }
    
    //    MARK: Controling Functions
    /**
     Initiates scanning for nearby peripherals.
     
     Call this method to start scanning for nearby Bluetooth peripherals in your SwiftUI app.
     */
    public func startScan() {
        peripheralStatus = .searching
        var scanOptions: [String: Any] = [CBCentralManagerScanOptionAllowDuplicatesKey: false]
        
        if let serviceUUIDs = serviceUUIDs {
            scanOptions[CBCentralManagerScanOptionSolicitedServiceUUIDsKey] = serviceUUIDs
        }
        
        centralManager?.scanForPeripherals(withServices: serviceUUIDs, options: scanOptions)
        print("Scan Started...")
    }
    
    /**
     Stops scanning for nearby peripherals.
     
     Call this method to halt the scanning process for nearby Bluetooth peripherals in your SwiftUI app.
     */
    public func stopScan() {
        peripheralStatus = .disconnected
        disconnectPeripheral()
        centralManager?.stopScan()
        print("Scan Stoped!")
    }
    
    /**
     Initiates a connection to a peripheral device.
     
     Call this method to establish a connection to a specific Bluetooth peripheral device in your SwiftUI app.
     */
    public func connectPeripheral(_ selectedPeripheral: Peripheral?) {
        guard let connectedPeripheral = selectedPeripheral else { return }
        self.connectedPeripheral = selectedPeripheral
        centralManager.connect(connectedPeripheral.peripheral, options: nil)
    }
    
    /**
     Terminates the connection with the currently connected peripheral device.
     
     Call this method to terminate the connection with the currently connected Bluetooth peripheral device in your SwiftUI app.
     */
    public func disconnectPeripheral() {
        guard let connectedPeripheral = connectedPeripheral else { return }
        centralManager.cancelPeripheralConnection(connectedPeripheral.peripheral)
    }
}

//MARK: CoreBluetooth CentralManager Delegete Functions
extension BluetoothModule: CBCentralManagerDelegate {
    /**
     - Description: Called when a peripheral is discovered during scanning.
     - Parameters:
        - central: The central manager object.
        - peripheral: The discovered peripheral.
        - advertisementData: A dictionary containing advertisement data.
        - rssi: The received signal strength indicator (RSSI) of the peripheral.
     */
    public func didDiscover(_ central: CBCentralManager, peripheral: CBPeripheral, advertisementData: [String : Any], rssi: NSNumber) {
        guard rssi.intValue < 0 else { return }
        
        if let serviceUUIDs = serviceUUIDs,
           let advertisedServices = advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID],
           !serviceUUIDs.contains(where: { advertisedServices.contains($0) }) {
            return
        }
        
        let peripheralName = advertisementData[CBAdvertisementDataLocalNameKey] as? String ?? peripheral.name ?? "No Name"
        
        let discoveredPeripheral = Peripheral(
            _peripheral: peripheral,
            _name: peripheralName,
            _advertisementData: advertisementData,
            _rssi: rssi,
            _discoverNumber: 0
        )
        
        if let index = discoverPeripherals.firstIndex(where: { $0.peripheral.identifier == peripheral.identifier }) {
            if discoverPeripherals[index].discoverNumber % 50 == 0 {
                discoverPeripherals[index].name = peripheralName
                discoverPeripherals[index].rssi = rssi.intValue
                discoverPeripherals[index].discoverNumber += 1
            } else {
                discoverPeripherals[index].discoverNumber += 1
            }
        } else {
            discoverPeripherals.append(discoveredPeripheral)
            peripheralStatus = .connecting
        }
        
        print("Did discover \(peripheralName)")
    }
    
    /**
     - Description: Called when the central manager's state is updated.
     - Parameters:
        - central: The central manager object.
     */
    public func didUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            isBleOn = true
        case .poweredOff:
            isBleOn = false
            resetConfiguration() 
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
    
    /**
     - Description: Called when a connection is successfully established with a peripheral.
     - Parameters:
        - center: The central manager object.
        - peripheral: The peripheral that is connected.
     */
    public func didConnect(_ center: CBCentralManager, peripheral: CBPeripheral) {
        guard let connectedPeripheral = connectedPeripheral else { return }
        peripheralStatus = .connected
        connectedPeripheral.peripheral.delegate = self
        connectedPeripheral.peripheral.discoverServices(nil)
        centralManager.stopScan()
        
        print("\(peripheral.name ?? "No name") is connected.")
    }
    
    /**
     - Description: Called when a connection attempt fails.
     - Parameters:
        - central: The central manager object.
        - peripheral: The peripheral that failed to connect.
        - error: The error that occurred during the connection attempt.
     */
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
    
    /**
     - Description: Called when a peripheral is disconnected.
     - Parameters:
        - central: The central manager object.
        - peripheral: The peripheral that is disconnected.
        - error: The error that occurred during disconnection, if any.
     */
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
    
    /**
     - Description: Called when services are discovered on a peripheral.
     - Parameters:
        - peripheral: The peripheral on which services are discovered.
        - error: The error that occurred during service discovery, if any.
     */
    public func didDiscoverServices(_ peripheral: CBPeripheral, error: Error?) {
        if let error = error {
            print("Error discovering services: \(error.localizedDescription)")
            return
        }
        
        peripheral.services?.forEach { [weak self] service in
            guard let self = self else { return }
            let foundService = Service(_uuid: service.uuid, _service: service)
            
            discoverServices.append(foundService)
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    /**
     - Description: Called when characteristics are discovered for a service on a peripheral.
     - Parameters:
        - peripheral: The peripheral on which characteristics are discovered.
        - service: The service for which characteristics are discovered.
        - error: The error that occurred during characteristic discovery, if any.
     */
    public func didDiscoverCharacteristics(_ peripheral: CBPeripheral, service: CBService, error: Error?) {
        if let error = error {
            print("Error discovering characteristics for service \(service.uuid): \(error.localizedDescription)")
            return
        }
        
        service.characteristics?.forEach { [weak self] characteristic in
            guard let self = self else { return }
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
    
    /**
     - Description: Called when the value of a characteristic is updated.
     - Parameters:
        - peripheral: The peripheral that owns the characteristic.
        - characteristic: The characteristic whose value is updated.
        - error: The error that occurred during value update, if any.
     */
    public func didUpdateValue(_ peripheral: CBPeripheral, characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Error updating value for characteristic \(characteristic.uuid): \(error.localizedDescription)")
            return
        }
        
        guard let characteristicValue = characteristic.value else { return }
        
        if let index = discoverCharacteristics.firstIndex(where: { $0.uuid.uuidString == characteristic.uuid.uuidString }) {
            
            discoverCharacteristics[index].readValue = characteristicValue.map({ String(format:"%02x", $0) }).joined()
        }
    }
    
    public func didWriteValue(_ peripheral: CBPeripheral, descriptor: CBDescriptor, error: Error?) {
        
    }
}
