import SwiftUI
import CoreBluetooth

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var bluetooth: BluetoothModule
    
    @State private var showDetailView = false
    @State var peripheral: Peripheral?
    
    var body: some View {
        NavigationView {
            VStack {
                if bluetooth.discoverPeripherals.count > 0 {
                    deviceListView
                }
            }
            .navigationTitle("Devices")
            .onChange(of: bluetooth.isBleOn) { newValue in
                if newValue {
                    bluetooth.startScan()
                } else {
                    bluetooth.stopScan()
                }
            }
        }
    }
}


#Preview {
    ContentView()
        .environmentObject(BluetoothModule())
}

extension ContentView {
    var deviceListView: some View {
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
                                            self.peripheral = peripheral
                                        }
                        }
                    }
                }
            }
            .background(
                NavigationLink(destination: DetailView(peripheral: peripheral), isActive: $showDetailView) {
                    EmptyView()
                }
                .opacity(0)
            )
        }
    
    func startTimer() {
        _ = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            startTimer()
        }
    }
}
