import 'package:ffi/ffi.dart';
import 'package:wiring_pi_serial/src/serial_native.dart';

/// Default path of the Wiring Pi library.
const _DEFAULT_PATH = '/usr/lib/libwiringPi.so';

/// Holds the instance of the Wiring Pi library.
class SerialInterface {
  SerialNative _native;

  /// Opens the Wiring Pi library. The [path] should point to the `.so` file.
  /// The default path is `/usr/lib/libwiringPi.so`.
  ///
  /// Check http://wiringpi.com/download-and-install/ on more information how
  /// to install Wiring Pi correctly.
  /// If you are using the Raspberry Pi 4B you might have to manually upgrade
  /// to version 2.52 (http://wiringpi.com/wiringpi-updated-to-2-52-for-the-raspberry-pi-4b/).
  SerialInterface({String path: _DEFAULT_PATH}) {
    _native = SerialNative(_DEFAULT_PATH);
  }
}

class SerialDevice {
  SerialNative _native;
  String _device;
  int _baud;

  /// Linux file descriptor for the serial port.
  int _deviceIdentifier = -1;

  /// Takes a instance of the `SerialInterface` class. Use the [device] value to
  /// specific the serial port you want to use. Default is `/dev/serial0`.
  /// [baud] defines the speed of the port and its default value is `6900`.
  ///
  /// To use the serial device you must call the [setup] method.
  SerialDevice(
    SerialInterface interface, {
    String device: "/dev/serial0",
    int baud: 9600,
  }) {
    _native = interface._native;
    this._device = device;
    this._baud = baud;
  }

  /// Path to the serial port.
  String get device => _device;

  /// Transmission speed of the port.
  int get baud => _baud;

  /// Opens the serial port. Throws a [SerialException] when failed.
  void setup() {
    final fd = _native.serialOpen(Utf8.toUtf8(device), baud);
    if (fd < 0)
      throw SerialException("Failed to initalize serial port.", device);
    _deviceIdentifier = fd;
  }

  /// Sends the [value] to the device.
  void sendByte(int value) {
    // TODO: Check for values longer than a byte
    _checkIfSetup();
    _native.serialPutchar(_deviceIdentifier, value);
  }

  /// Sends the [string] to the device.
  void sendString(String string) {
    _checkIfSetup();
    _native.serialPuts(_deviceIdentifier, Utf8.toUtf8(string));
  }

  /// Returns the list of data available on the serial device.
  List<int> getValues() {
    _checkIfSetup();
    List<int> values = [];
    int dataAvail = _native.serialDataAvail(_deviceIdentifier);

    for (int i = 0; i < dataAvail; i++) {
      int value = _native.serialGetchar(_deviceIdentifier);
      values.add(value);
    }
    return values;
  }

  /// This discards all data received, or waiting to be send down the given device.
  void clear() {
    _checkIfSetup();
    return _native.serialFlush(_deviceIdentifier);
  }

  /// Closes the serial port. Should be called if serial port is not in use anymore.
  void closePort() {
    _checkIfSetup();
    _native.serialClose(_deviceIdentifier);
    _deviceIdentifier = -1;
  }

  /// Checks if the [_deviceIdentifier] is negativ and throws a [StateError]
  /// when true.
  void _checkIfSetup() {
    if (_deviceIdentifier < 0)
      throw StateError(
        """
        Serial port has not yet been setup. You must call the 'setup' method
        before using the device. Device path: $device
        """,
      );
  }
}

class SerialException implements Exception {
  final String _message;
  final String _device;

  SerialException(this._message, this._device);

  @override
  String toString() => "$_message (Device: $_device)";
}
