# Vector SIL Kit Adapter for Byte Stream Sockets
This collection of software is provided to illustrate how the [Vector SIL Kit](https://github.com/vectorgrp/sil-kit/) can bridge any socket and transmit the content between it and a pair of SIL Kit Topics.

This repository contains instructions to set up development environment and build the adapter, as well as a simple demo to showcase the functionality.

# Getting Started
Those instructions assume you use WSL (Ubuntu) or a Linux OS for building and running the adapter (nevertheless it is also possible to do this directly on a Windows system, with the exception of setting up the QEMU image), and use ``bash`` as your interactive shell.

## a) Getting Started with pre-built Adapter and Demos
Download a preview or release of the adapter directly from [Vector SIL Kit for Byte Stream Sockets Releases](https://github.com/vectorgrp/sil-kit-adapters-byte-stream-socket/releases).

If not already existent on your system you should also download a SIL Kit Release directly from [Vector SIL Kit Releases](https://github.com/vectorgrp/sil-kit/releases). You will need this for being able to start a sil-kit-registry.

## b) Getting Started with self-built Adapter and Demos
This section specifies steps you should do if you have just cloned the repository.

Before any of those topics, please change your current directory to the top-level in the ``sil-kit-adapters-byte-stream-socket`` repository:

    cd /path/to/sil-kit-adapters-byte-stream-socket

### Fetch Third Party Software
The first thing that you should do is initializing the submodules to fetch the required third party softwares:

    git submodule update --init --recursive

### Build the Adapter and the Demos
To build the adapter and demos, you will need a SIL Kit package ``SilKit-x.y.z-$platform`` for your platform. You can download it directly from [Vector SIL Kit Releases](https://github.com/vectorgrp/sil-kit/releases).
The easiest way would be to download it with your web browser, unzip it and place it on your Windows file system, where it also can be accessed by WSL.

The adapter and demos are built using ``cmake``:

    cmake --preset linux-release -DSILKIT_PACKAGE_DIR=/path/to/SilKit-x.y.z-$platform/ 
    cmake --build --preset linux-release --parallel
    

> If you have a self-built or pre-built version of SIL Kit, you can build the adapter against it by setting SILKIT_PACKAGE_DIR to the path, where the bin, include and lib directories are.

> If you have SIL Kit installed on your system, you can build the adapter against it, even by not providing SILKIT_PACKAGE_DIR to the installation path at all. Hint: Be aware, if you are using WSL2 this may result in issue where your Windows installation of SIL Kit is found. To avoid this specify SILKIT_PACKAGE_DIR.

> If you don't provide a specific path for SILKIT_PACKAGE_DIR and there is no SIL Kit installation on your system, a SIL Kit release package (the default version listed in CMakeLists.txt) will be fetched from github.com and the adapter will be built against it.

The adapter and demo executables will be available in the ``bin`` directory as well as the ``SilKit.dll`` if you are on Windows. Additionally the ``SilKit.lib`` on Windows and the ``libSilKit.so`` on Linux are automatically copied to the ``lib`` directory.


# Run the sil-kit-adapter-byte-stream-socket
This application allows the user to attach to a web socket in order to bridge it to the SIL Kit:

All data received from the socket will be sent to the publish topic specified to sil-kit-adapter-byte-stream-socket.
All data received on the subscribed topic specified to sil-kit-adapter-byte-stream-socket will be sent to the socket.


Before you start the adapter there always needs to be a sil-kit-registry running already. Start it e.g. like this:

    /path/to/SilKit-x.y.z-$platform/SilKit/bin/sil-kit-registry --listen-uri 'silkit://0.0.0.0:8501'

The application takes the following command line arguments (defaults in curly braces if you omit the switch):

    sil-kit-adapter-byte-stream-socket [--name <participant's name{SilKitAdapterByteStreamSocket}>]
      [--configuration <path to .silkit.yaml or .json configuration file>]
      [--registry-uri silkit://<host{localhost}>:<port{8501}>]
      [--log <Trace|Debug|Warn|{Info}|Error|Critical|Off>]
     [[--socket-to-bytestream
         <host>:<port>,
        [<namespace>::]<toChardev topic name>[~<subscriber's name>]
           [[,<label key>:<optional label value>
            |,<label key>=<mandatory label value>
           ]],
        [<namespace>::]<fromChardev topic name>[~<publisher's name>]
           [[,<label key>:<optional label value>
            |,<label key>=<mandatory label value>
           ]]
     ]]

There needs to be at least one ``--socket-to-bytestream`` argument, and each socket need to be unique.

SIL Kit-specific CLI arguments will be overwritten by the config file passed by ``--configuration``.

> **Example:**
Here is an example that runs the Byte Stream Socket Adapter and demonstrates the basic form of parameters that the adapter takes into account: 
> 
>     sil-kit-adapter-byte-stream-socket --name BytesSocketBridge --socket-to-bytestream localhost:81,toSocket,fromSocket
>
> In this example, the adapter has `BytesSocketBridge` as participant name, and uses the default values for SIL Kit URI connection (`silkit://localhost:8501`). `localhost` and port `81` are used to establish a socket connection to a source of bidirectional data. When the socket is emitting data, the adapter will send it to the topic named `fromSocket`, and when data arrive on the `toSocket` topic, they are sent through the socket.

## Socat Demo
This demo application allows the user to attach a `socat` process to the SIL Kit in the form of a DataPublisher/DataSubscriber, and echo the data sent forward and back via the SIL Kit.

`socat` is a Linux utility which allows to pipe data between two channels, and it supports a wide range of protocols including web sockets.

For instance, as is the case of the demo here, you can set up forwarding the standard input and output of a terminal to a websocket (TCP on port 81) waiting for a peer with the following command:

    socat TCP4-LISTEN:1234 stdio

Since `socat` is a Linux utility, you may use WSL to use it under Windows, or use the single-shot script `tools\socat.ps1` to use the demo 

> Note that an interrupted `socat` may still be running, if you get an error that reads `Address already in use` you may try to remove all leftover processes by executing e.g. `killall socat`.

Remember: before you start the adapter, there always needs to be a sil-kit-registry running already. Start it e.g. like this:

    /path/to/SilKit-x.y.z-$platform/SilKit/bin/sil-kit-registry --listen-uri 'silkit://0.0.0.0:8501'

Now you can attach without error a Byte Stream Socket Adapter to it:

    ./bin/sil-kit-adapter-byte-stream-socket --socket-to-bytestream localhost:1234,toSocket,fromSocket --log Debug

The `--log Debug` argument requests the sil-kit-adapter-byte-stream-socket to print out `Debug` level information in the logging outputs (which by default is `stdio`). Therefore you will see the adapter sending to the topic the data that you input with `socat`. For instance, if you type (finish by hitting enter):
````
Test 1
````

You will notice the following output in the sil-kit-adapter-byte-stream-socket terminal:
````
[date time] [SilKitAdapterByteStreamSocket] [debug] Updating participant status for SilKitAdapterByteStreamSocket from ReadyToRun to Running
[date time] [SilKitAdapterByteStreamSocket] [debug] The participant state has changed for SilKitAdapterByteStreamSocket
Press CTRL + C to stop the process...
[date time] [SilKitAdapterByteStreamSocket] [debug] Adapter >> SIL Kit: Test 1

````

> The log will contain all characters being received from the socket, and since `socat` is transmitting a newline character when you type `Test 1` it will show up. It is more prominently visible in the next step when you do have a response.

Now you can run the `sil-kit-demo-byte-stream-echo-device` process:

    `./bin/sil-kit-demo-bytestream-echo-device --log Debug`

It is designed to subscribe to the topic `fromSocket` in order to send all messages received there to the topic `toSocket`. Type `Test 2` into `socat`'s standard input, then you will see the following result:

````
Test 2
Test 2
````

You will see what you inputted being printed again, and also the following in the output in the sil-kit-adapter-byte-stream-socket terminal:

````
[date time] [SilKitAdapterByteStreamSocket] [debug] Adapter >> SIL Kit: Test 2

[date time] [SilKitAdapterByteStreamSocket] [debug] SIL Kit >> Adapter: Test 2

````

## Observing and testing the echo demo with CANoe (CANoe 17 SP3 or newer)

[//]: <> (TODO: restore a SIL Kit configuration file)

Before you can connect CANoe to the SIL Kit network you should adapt the `RegistryUri` in `./demos/SilKitConfig_CANoe.silkit.yaml` to the IP address of your system where your sil-kit-registry is running (in case of a WSL2 Ubuntu image e.g. the IP address of Eth0). The configuration file is referenced by both following CANoe use cases (Desktop Edition and Server Edition).

CANoe's Publisher/Subscriber counterpart are Distributed Objects. By nature, they are meant to convey their state to and from
CANoe, but not simultaneously. Therefore, this CANoe demo will contain 2 such objects in order to demonstrate the
observation capability.

Here is a small drawing to illustrate how CANoe observes the topics (the observation happens in SIL Kit's network):
```
      CANoe Observation
                   \
+----[SIL Kit]----+ \        > fromSocket >         +----[SIL Kit]----+
|                 |__)______________________________|                 |
| ChardevAdapter  |                                 |    EchoDevice   |    
|                 |_________________________________|                 |
|                 |          <  toSocket  <       / |                 |
+-----------------+                              (  +-----------------+
                                                  \
                                               CANoe Observation
```
### CANoe Desktop Edition
Load the ``Bytestream_observer.cfg`` from the ``./demos/CANoe`` directory and start the measurement.
#### Tests in CANoe Desktop Edition
Optionally you can also start the test unit execution of included test configuration. While the demo is running, these tests should be successful. The advised way to "run" the demo for the test to be successful while you focus on it is to execute the following commands in the terminal:
```
while sleep 1; do echo Test; done | socat TCP4-LISTEN:1234 stdio
```

### CANoe4SW Server Edition (Windows)
You can also run the same test set with ``CANoe4SW SE`` by executing the following PowerShell script ``./demos/CANoe4SW_SE/run.ps1``. The test cases are executed automatically and you should see a short test report in PowerShell after execution.

### CANoe4SW Server Edition (Linux)
You can also run the same test set with ``CANoe4SW SE (Linux)``. At first you have to execute the PowerShell script ``./demos/CANoe4SW_SE/createEnvForLinux.ps1`` on your Windows system by using tools of ``CANoe4SW SE (Windows)`` to prepare your test environment for Linux. In ``./demos/CANoe4SW_SE/run.sh`` you should set ``canoe4sw_se_install_dir`` to the path of your ``CANoe4SW SE`` installation in your WSL. Afterwards you can execute ``./demos/CANoe4SW_SE/run.sh`` in your WSL. The test cases are executed automatically and you should see a short test report in your terminal after execution.

[//]: <> (TODO: finish this part)

## Demo with CANoe interaction (CANoe 17 SP3 or newer)
This demo showcases sending data from CANoe Desktop to the serial port of QEMU.

Before you can connect CANoe to the SIL Kit network you should adapt the `RegistryUri` in `./chardev/demos/SilKitConfig_CANoe.silkit.yaml` to the IP address of your system where your sil-kit-registry is running (in case of a WSL2 Ubuntu image e.g. the IP address of Eth0).

When you will start the measurement, CANoe will subscribe only to the ``fromChardev`` topic and set itself up as
a publisher on the other, ``toChardev``.

After following the common demo steps above, first launch the adapter, which connects to the registry (to connect to other participants) and to QEMU,
to transmit the serial data written to ``/dev/ttyS1`` inside QEMU through SIL Kit, and vice-versa:
```
./bin/sil-kit-adapter-byte-stream-socket --socket-to-bytestream localhost:23456,Namespace::toChardev,VirtualNetwork=Default,Instance=EchoDevice,Namespace::fromChardev,VirtualNetwork:Default,Instance:Adapter --configuration ./chardev/demos/SilKitConfig_Adapter.silkit.yaml
Creating participant 'SilKitAdapterByteStreamSocket' at silkit://localhost:8501
[date time] [SilKitAdapterByteStreamSocket] [info] Creating participant 'SilKitAdapterByteStreamSocket' at 'silkit://localhost:8501', SIL Kit version: 4.0.19
[date time] [SilKitAdapterByteStreamSocket] [info] Connected to registry at 'tcp://127.0.0.1:8501' via 'tcp://127.0.0.1:49224' (silkit://localhost:8501)
connect success
    ...
```

Then, you can start a dump of data sent through the link from the outside:
```
root@silkit-qemu-demos-guest:~# cat /dev/ttyS1&
```
Finally, launch CANoe and load the
``Bytestream_observer.cfg`` from the ``./demos/CANoe`` directory.

Here is a small drawing to illustrate how CANoe is connected to QEMU:
```
+----[SIL Kit]----+          > fromChardev >         +----[SIL Kit]----+
|                 |__________________________________|                 |
| ChardevAdapter  |                                  |      CANoe      |    
|                 |__________________________________|                 |
|                 |          <  toChardev  <         |                 |
+-----------------+                                  +-----------------+
```

Similarly to the previous demo, any text sent to the ``/dev/ttyS1`` file inside QEMU will show up in 
CANoe as data in the small widget for ``fromChardev``. While text inputted in CANoe's ``toChardev``
field will be outputted by the ``cat`` inside QEMU once you press the "Send" button.

## Byte-oriented demos (CANoe 17 SP3 or newer)

These demos showcase binary transfer and conversion from the chardev channel to a DataPublisher-DataSubscriber pair for CANoe communication.

Before you can connect CANoe to the SIL Kit network you should adapt the ``RegistryUri`` in `./chardev/demos/SilKitConfig_CANoe.silkit.yaml` to the IP address of your system where your sil-kit-registry is running (in case of a WSL2 Ubuntu image e.g. the IP address of Eth0).

Then launch the adapter and prepare to dialog with CANoe on its byte-oriented topics:
```
./bin/sil-kit-adapter-byte-stream-socket --socket-to-bytestreamlocalhost:23456,Namespace::degrees_user,VirtualNetwork=Default,Instance=UserTemp,Namespace::degrees_sensor,VirtualNetwork:Default,Instance:SensorTemp --registry-uri silkit://localhost:8501 --log Debug
```