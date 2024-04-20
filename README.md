# BluetoothPulse

 ![](https://img.shields.io/badge/platform-iOS-d3d3d3) ![](https://img.shields.io/badge/iOS-15.0%2B-43A6C6) ![](https://img.shields.io/badge/Swift-5-F86F15)

This library contains a SwiftUI Bluetooth Module designed to facilitate Bluetooth connectivity within SwiftUI apps. Whether you're building an iOS, macOS app, this module provides a comprehensive solution for integrating Bluetooth functionality seamlessly into your SwiftUI project.

#### Features:
  - Connection Status Tracking: Monitor the status of Bluetooth connections with clear and concise enums, facilitating easy handling of various connection states.
  - Peripheral Discovery: Discover nearby Bluetooth peripherals and retrieve relevant information such as local name, advertisement data, and signal strength.
  - Peripheral Connection: Establish connections with Bluetooth peripherals and handle connection events seamlessly.
  - Service and Characteristic Discovery: Discover services and characteristics of connected peripherals for data exchange.
  - SwiftUI Integration: Designed for use within SwiftUI applications, ensuring a smooth and native-like user experience.

## Table of contents
   - [Requirements](#requirements)
   - [Installation](#installation)
     - [Swift Package Manager (SPM)](#spm)
   - [Usage](#usage)
   - [Contribution](#contribution)
   - [License](#license)

## Requirements
<a id="requirements"></a>
   - SwiftUI
   - iOS 15.0 or above

## Installation
<a id="installation"></a>
You can access Tabfinity through [Swift Package Manager](https://github.com/apple/swift-package-manager).
### Swift Package Manager (SPM)
<a id="spm"></a>
In xcode select:
```
File > Swift Packages > Add Package Dependency...
```
Then paste this URL:
```
https://github.com/MMMagicCoder/BluetoothPulse.git
```

## Usage

<a id="usage"></a>

- Initialization: Create an instance of BluetoothModule to start managing Bluetooth connections.

```swift
let bluetoothModule = BluetoothModule()
```

- Scan for Peripherals: Start scanning for nearby peripherals using the startScan() method.
```swift
bluetoothModule.startScan()
```

- Connect to a Peripheral: Initiate a connection to a discovered peripheral by calling connectPeripheral(_:) method with the selected peripheral.
```swift
bluetoothModule.connectPeripheral(selectedPeripheral)
```

- Access Connected Peripheral: Access the currently connected peripheral through the connectedPeripheral variable.
```swift
let connectedPeripheral = bluetoothModule.connectedPeripheral
```

- Discover Peripherals, Services, and Characteristics: Access the discovered peripherals, services, and characteristics through the corresponding variables.
```swift
let discoveredPeripherals = bluetoothModule.discoverPeripherals
let discoveredServices = bluetoothModule.discoverServices
let discoveredCharacteristics = bluetoothModule.discoverCharacteristics
```

Other useful functionalities include:

- Stop Scanning: Halt the scanning process for nearby peripherals using the stopScan() method.
```swift
bluetoothModule.stopScan()
```

- Disconnect from a Peripheral: Terminate the connection with the currently connected peripheral using the disconnectPeripheral() method.
```swift
bluetoothModule.disconnectPeripheral()
```

## Contribution
<a id="contribution"></a>
If you encounter any challenges, please feel free to [open an issue](https://github.com/MMMagicCoder/bluetoothPulse/issues/new). Additionally, we welcome and appreciate pull requests for any improvements or contributions.

## License
<a id="license"></a>
bluetoothPulse is under the terms and conditions of the MIT license.
```
MIT License

Copyright (c) 2024 Mohammad Mahdi Moayeri

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
