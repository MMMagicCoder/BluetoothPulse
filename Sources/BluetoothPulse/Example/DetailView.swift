import SwiftUI
import CoreBluetooth

struct DetailView: View {
    let peripheral: Peripheral
    
    var body: some View {
        List {
            Section("ID") {
                HStack {
                    Text("ID: ")
                    Text("\(peripheral.id)")
                }
            }
            
            Section("Services") {
//                ForEach(peripheral.advertisementData)
            }
        }
        .navigationTitle(peripheral.name)
    }
}
