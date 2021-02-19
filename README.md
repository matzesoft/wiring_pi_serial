# Wiring Pi Serial

Dart implementation of the Wiring Pi serial library.

I mainly created this package for one of my own projects, so I haven't done a lot of testing yet. But I still hope this makes the creation of your flutter-pi app (or whatever you create) easier.

## Installing Wiring Pi

Visit this [guide](http://wiringpi.com/download-and-install/) to install the Wiring Pi library on your Raspberry Pi. If your are using a Raspberry Pi 4B you might also check this [post](http://wiringpi.com/wiringpi-updated-to-2-52-for-the-raspberry-pi-4b/).

The library (`.so` file) should be located under `/usr/lib/libwiringPi.so`.

## Using the package

The first thing todo is to create the `SerialDevice`. It takes the path to the device (default: `/dev/serial0`) and the baud rate of the connection (default: `9600`). Afterwards call the `setup` method.
```dart
final serialDevice = SerialDevice();
serialDevice.setup();
```

The `SerialDevice` is now setup and ready to use. You can use all the commands mentioned in the [Wiring Pi documentation](http://wiringpi.com/reference/serial-library/), except the `serialPrintf` method.
```dart
device.sendByte(0x69);
device.sendString("Hello Serial Device!");

final values = device.getValues();
for (int i = 0; i < values.length; i++) {
    print("Value at $i: ${values[i]}");
}

device.closePort();
```

If any of the methods fails a `SerialException` will be throwen.
