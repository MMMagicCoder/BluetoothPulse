import SwiftUI
import CoreBluetooth

struct DetailView: View {
    @EnvironmentObject var bluetooth: BluetoothModule
    let peripheral: Peripheral!
    
    let defaultUUID: String = "00000000-0000-0000-0000-000000000000"
    var advertisedServices: [CBUUID] {
        guard let services = peripheral.peripheral.services else {
            return []
        }
        return services.map { $0.uuid }
    }
    
    var body: some View {
        List {
            Section("ID") {
                HStack {
                    Text("ID: ")
                    Text("\(peripheral.id)")
                        .font(.caption)
                        .foregroundColor(Color(red: 0.7, green: 0.7, blue: 0.7))
                }
            }
            
            ForEach(advertisedServices, id: \.self) { service in
                Section("SERVICE: \(service)") {
                    ForEach(0..<bluetooth.discoverServices.count) { i in
                        if bluetooth.discoverServices[i].uuid == service {
                            ForEach(0..<bluetooth.discoverCharacteristics.count) { j in
                                if bluetooth.discoverServices[i].uuid == bluetooth.discoverCharacteristics[j].service.uuid {
                                    NavigationLink {
                                        Text(bluetooth.discoverCharacteristics[j].readValue)
                                    } label: {
                                        Text("\(bluetooth.discoverCharacteristics[j].uuid)")
                                    }

                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(peripheral.name)
    }
}
