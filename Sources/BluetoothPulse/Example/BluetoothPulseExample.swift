import SwiftUI
import CoreBluetooth

struct BluetoothPulseExample: View {
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var bluetooth = CoreBluetoothModule()
    @State private var showDetailView = false
    
    var body: some View {
        NavigationView {
            ZStack {
                if bluetooth.discoverPeripherals.count > 0 {
                    List {
                        Section("Devices") {
                            ForEach(bluetooth.discoverPeripherals) { peripheral in
                                HStack {
                                    Button(action: {
                                        bluetooth.connectPeripheral(peripheral)
                                    }, label: {
                                        Text(peripheral.peripheral.name ?? "No name")
                                            .foregroundColor(colorScheme == .dark ? .white : .black)
                                    })
                                    
                                    Spacer()
                                    
                                            Text(bluetooth.connectedPeripheral == peripheral ? "Connected" : "Not Connected")
                                                .font(.subheadline)
                                                .foregroundColor(Color(red: 0.7, green: 0.7, blue: 0.7))
                                            
                                            Image(systemName: "info.circle")
                                                .font(.title2)
                                                .foregroundColor(.blue)
                                                .onTapGesture {
                                                    showDetailView = true
                                                }
                                }
                            }
                        }
                    }
                    .background(
                        NavigationLink(destination: DetailView(), isActive: $showDetailView) {
                            EmptyView()
                        }
                        .opacity(0)
                    )
                }
            }
            .navigationTitle("Devices")
            .onAppear {
                bluetooth.startScan()
            }
            .onDisappear {
                bluetooth.stopScan()
            }
        }
    }
}
