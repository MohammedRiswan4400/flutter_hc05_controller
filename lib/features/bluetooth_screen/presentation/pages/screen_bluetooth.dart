import '../../bluetooth.dart';

class BluetoothApp extends StatefulWidget {
  const BluetoothApp({super.key});
  @override
  State<BluetoothApp> createState() => _BluetoothAppState();
}

class _BluetoothAppState extends State<BluetoothApp> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  BluetoothConnection? connection;
  bool get isConnected => connection != null && connection!.isConnected;

  List<BluetoothDevice> _devicesList = [];
  BluetoothDevice? _device;
  bool _connected = false;
  bool _isButtonUnavailable = false;

  @override
  void initState() {
    super.initState();
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    _enableBluetooth();

    FlutterBluetoothSerial.instance.onStateChanged().listen((
      BluetoothState state,
    ) {
      setState(() {
        _bluetoothState = state;
        if (_bluetoothState == BluetoothState.STATE_OFF) {
          _isButtonUnavailable = true;
        }
        _getPairedDevices();
      });
    });
  }

  Future<void> _enableBluetooth() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    _bluetoothState = await FlutterBluetoothSerial.instance.state;

    if (_bluetoothState == BluetoothState.STATE_OFF) {
      await FlutterBluetoothSerial.instance.requestEnable();
      await _getPairedDevices();
    } else {
      await _getPairedDevices();
    }
  }

  Future<void> _getPairedDevices() async {
    List<BluetoothDevice> list = [];
    try {
      list = await _bluetooth.getBondedDevices();
    } catch (e) {
      print("Error getting bonded devices: $e");
    }

    if (!mounted) return;
    setState(() {
      _devicesList = list;
    });
  }

  void _connect() async {
    if (_device == null) return;

    if (!isConnected) {
      bool success = await _connectToDevice();
      if (success) {
        setState(() => _connected = true);
      }
    }
  }

  Future<bool> _connectToDevice() async {
    try {
      setState(() => _isButtonUnavailable = true);

      connection = await BluetoothConnection.toAddress(_device!.address);
      print('Connected to the device');

      connection!.input!
          .listen((Uint8List data) {
            // Data received from HC-05
            print('Data incoming: ${ascii.decode(data)}');
            connection!.output.add(data); // Sending data back (Echo)
          })
          .onDone(() {
            if (mounted) {
              setState(() {
                _connected = false;
                _isButtonUnavailable = false;
              });
            }
          });

      setState(() => _isButtonUnavailable = false);
      return true;
    } catch (e) {
      print('Cannot connect, exception occured');
      if (mounted) {
        setState(() {
          _connected = false;
          _isButtonUnavailable = false;
        });
      }
      return false;
    }
  }

  void _disconnect() async {
    await connection?.close();
    if (!connection!.isConnected) {
      setState(() {
        _connected = false;
        _isButtonUnavailable = false;
      });
    }
  }

  void _sendData(String data) async {
    if (connection?.isConnected ?? false) {
      connection!.output.add(Uint8List.fromList(utf8.encode("$data\r\n")));
      await connection!.output.allSent;
      print("Data sent: $data");
    }
  }

  @override
  void dispose() {
    if (isConnected) {
      connection?.dispose();
      connection = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("HC-05 Flutter Controller"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          // 1. Device Dropdown
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Device:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                DropdownButton<BluetoothDevice>(
                  items: _devicesList.map((device) {
                    return DropdownMenuItem(
                      value: device,
                      child: Text(device.name ?? "Unknown"),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _device = value);
                  },
                  value: _devicesList.isNotEmpty ? _device : null,
                  hint: const Text("Select HC-05"),
                ),
              ],
            ),
          ),

          // 2. Connect/Disconnect Button
          ElevatedButton(
            onPressed: _isButtonUnavailable
                ? null
                : _connected
                ? _disconnect
                : _connect,
            child: Text(_connected ? 'Disconnect' : 'Connect'),
          ),

          const Divider(),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Controls",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),

          // 3. Control Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _connected ? () => _sendData("1") : null,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text("ON"),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: _connected ? () => _sendData("0") : null,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text("OFF"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
