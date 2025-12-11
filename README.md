# Vector SIL Kit Adapter for Byte Stream Socket
[![Vector Informatik](https://img.shields.io/badge/Vector%20Informatik-rgb(180,0,50))](https://www.vector.com/int/en/)
[![SocialNetwork](https://img.shields.io/badge/vectorgrp%20LinkedIn®-rgb(0,113,176))](https://www.linkedin.com/company/vectorgrp/)\
[![ReleaseBadge](https://img.shields.io/github/v/release/vectorgrp/sil-kit-adapters-byte-stream-socket.svg)](https://github.com/vectorgrp/sil-kit-adapters-byte-stream-socket/releases)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/vectorgrp/sil-kit-adapters-qemu/blob/main/LICENSE)
[![Win & Linux Builds](https://github.com/vectorgrp/sil-kit-adapters-byte-stream-socket/actions/workflows/build-linux-and-windows-release.yml/badge.svg)](https://github.com/vectorgrp/sil-kit-adapters-byte-stream-socket/actions/workflows/build-linux-and-windows-release.yml)
[![SIL Kit](https://img.shields.io/badge/SIL%20Kit-353b42?logo=github&logoColor=969da4)](https://github.com/vectorgrp/sil-kit)

This collection of software is provided to illustrate how the [Vector SIL Kit](https://github.com/vectorgrp/sil-kit/) can bridge any socket and transmit the content between it and a pair of SIL Kit Topics.

This repository contains instructions to set up development environment and build the adapter, as well as a simple demo to showcase the functionality.

# Getting Started
Those instructions assume you use WSL (Ubuntu) or a Linux OS for building and running the adapter (nevertheless it is also possible to do this directly on a Windows system, and use ``bash`` as your interactive shell.

## a) Getting Started with pre-built Adapter and Demos
Download a preview or release of the adapter directly from [Vector SIL Kit for Byte Stream Socket Releases](https://github.com/vectorgrp/sil-kit-adapters-byte-stream-socket/releases).

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
This application allows the user to attach to a network socket in order to bridge it to the SIL Kit:

All data received from the socket will be sent to the publish topic specified to sil-kit-adapter-byte-stream-socket.
All data received on the subscribed topic specified to sil-kit-adapter-byte-stream-socket will be sent to the socket.


Before you start the adapter there always needs to be a sil-kit-registry running already. Start it e.g. like this:

    /path/to/SilKit-x.y.z-$platform/SilKit/bin/sil-kit-registry --listen-uri 'silkit://0.0.0.0:8501'

The application takes the following command line arguments (defaults in curly braces if you omit the switch):

    sil-kit-adapter-byte-stream-socket [--name <participant's name{SilKitAdapterByteStreamSocket}>]
      [--configuration <path to .silkit.yaml or .json configuration file>]
      [--registry-uri silkit://<host{localhost}>:<port{8501}>]
      [--log <Trace|Debug|Warn|{Info}|Error|Critical|Off>]
     [[--socket-to-byte-stream
         <host>:<port>,
        [<namespace>::]<toAdapter topic name>[~<subscriber's name>]
           [[,<label key>:<optional label value>
            |,<label key>=<mandatory label value>
           ]],
        [<namespace>::]<fromAdapter topic name>[~<publisher's name>]
           [[,<label key>:<optional label value>
            |,<label key>=<mandatory label value>
           ]]
     ]]
     [[--unix-socket-to-byte-stream
         <path to socket identifier>,
        [<namespace>::]<toAdapter topic name>[~<subscriber's name>]
           [[,<label key>:<optional label value>
            |,<label key>=<mandatory label value>
           ]],
        [<namespace>::]<fromAdapter topic name>[~<publisher's name>]
           [[,<label key>:<optional label value>
            |,<label key>=<mandatory label value>
           ]]
     ]]
     [--version]
     [--help]

There needs to be at least one ``--socket-to-byte-stream`` or ``--unix-socket-to-byte-stream`` argument, and each socket needs to be unique.

SIL Kit-specific CLI arguments will be overwritten by the config file passed by ``--configuration``.

> **Example:**
Here is an example that runs the Byte Stream Socket Adapter and demonstrates the basic form of parameters that the adapter takes into account: 
> 
>     sil-kit-adapter-byte-stream-socket --name BytesSocketBridge --socket-to-byte-stream localhost:81,toSocket,fromSocket
>
> In this example, the adapter has `BytesSocketBridge` as participant name, and uses the default values for SIL Kit URI connection (`silkit://localhost:8501`). `localhost` and port `81` are used to establish a socket connection to a source of bidirectional data. When the socket is emitting data, the adapter will send them to the topic named `fromSocket`, and when data arrive on the `toSocket` topic, they are sent through the socket.

## Echo Server Demo
This demo application allows the user to attach a `socat` process to the SIL Kit in the form of a DataPublisher/DataSubscriber, and echo the data sent forward and back via the SIL Kit.

`socat` is a Linux utility which allows to pipe data between two channels, and it supports a wide range of protocols including network sockets.

In this demo, the echo server using socat has been wrapped into the `echo_server.sh` script located in the `tools` folder. You can run it as follows, it will wait for a peer on port 1234:

```
./tools/echo_server.sh 1234
[info] TCP server awaiting connection on port 1234...
[info] Press CTRL + C to stop the process...
```

> Note that an interrupted `socat` may still be running, if you get an error that reads `Address already in use` you may try to remove all leftover processes by executing e.g. `killall socat`.

> If you are using a Windows system, you can run the `./tools/echo_server.ps1` script in the same way.

Remember: before you start the adapter, there always needs to be a sil-kit-registry running already. Start it e.g. like this:

    /path/to/SilKit-x.y.z-$platform/SilKit/bin/sil-kit-registry --listen-uri 'silkit://0.0.0.0:8501'

Now you can start the Byte Stream Socket Adapter:

    ./bin/sil-kit-adapter-byte-stream-socket --socket-to-byte-stream localhost:1234,toSocket,fromSocket --log Debug

The `--log Debug` argument requests the sil-kit-adapter-byte-stream-socket to print out `Debug` level information in the logging outputs (which by default is `stdio`). 

### Automatic Sender Demo Participant

The sil-kit-demo-byte-stream-socket-auto-sender application is a SIL Kit participant that automatically sends `test message <id>` through the toSocket topic and receives echoed data on the fromSocket topic. You can run it as follows:
```
./bin/sil-kit-demo-byte-stream-socket-auto-sender
[date time] [ByteStreamSocketAutoSender] [info] Creating participant, ParticipantName: ByteStreamSocketAutoSender, RegistryUri: silkit://localhost:8501, SilKitVersion: 5.0.2
[date time] [ByteStreamSocketAutoSender] [info] Connected to registry at 'tcp://127.0.0.1:8501' via 'tcp://127.0.0.1:53768' (local:///tmp/SilKitRegi54d2044f72372c68.silkit, tcp://localhost:8501)
[date time] [ByteStreamSocketAutoSender] [info] Press CTRL + C to stop the process...
[date time] [ByteStreamSocketAutoSender] [info] AutoSender >> Adapter: test message 0
[date time] [ByteStreamSocketAutoSender] [info] Adapter >> AutoSender: test message 0
[date time] [ByteStreamSocketAutoSender] [info] AutoSender >> Adapter: test message 1
[date time] [ByteStreamSocketAutoSender] [info] Adapter >> AutoSender: test message 1
...
```

> The `<id>` starts to 0 and increments by one every two seconds.

> The demo participant connects to the registry at `localhost:8501` by default. Run `./bin/sil-kit-demo-byte-stream-socket-auto-sender --help` to see additional information.

On the terminal where you started the echo_server you should see the following output:
````
test message 0< 2025/11/27 10:15:28.105357  length=14 from=0 to=13
test message 0> 2025/11/27 10:15:30.108935  length=14 from=14 to=27
test message 1< 2025/11/27 10:15:30.109592  length=14 from=14 to=27
test message 1> 2025/11/27 10:15:32.109546  length=14 from=28 to=41
````

**Note:** If you want to use UNIX domain sockets instead of TCP sockets, the adapter can be started as follows 
```
./bin/sil-kit-adapter-byte-stream-socket --unix-socket-to-byte-stream PATH,toSocket,fromSocket --log Debug
```

where PATH needs to be replaced by an actual filesystem location representing the socket address. If you are using a Linux OS, you may choose PATH=/tmp/socket. In case of a Windows system, PATH=C:\Users\MyUser\AppData\Local\Temp\qemu.socket is a possible choice. 
Note that the socat command also needs to be adapted in the echo_server.sh script:

    socat UNIX-LISTEN:PATH,fork SYSTEM:"cat"

In the following diagram you can see the whole setup. It illustrates the data flow going through each component involved.
```
                +--[ echo_server ]--+                              +--[ SIL Kit Adapter Byte Stream Socket ]--+
                |   socket <1234>   |< -------------------------- >|                                          |
                +-------------------+                              +------------------------------------------+
                                                                                        ^
                                                                                        |
                                                                                        |
                                                SIL Kit topics:                         |
                                                                                        |
    +--[ SilKitDemoByteStream- ]--+               > toSocket >                          v
    |     SocketAutoSender        |----        ------------------            +--[ SIL Kit Registry ]--+
    +-----------------------------+    |      /                  \           |                        |
                                       |------                    -----------|                        |
       +----[ Vector CANoe ]---+       |      \                  /           |                        |
       |                       |-------        ------------------            |                        |
       +-----------------------+                 < fromSocket <              +------------------------+
```

## Observing and testing the echo demo with CANoe (CANoe 19 SP3 or newer)

Before you can connect CANoe to the SIL Kit network you should adapt the `RegistryUri` in `./demos/SilKitConfig_CANoe.silkit.yaml` to the IP address of your system where your sil-kit-registry is running (in case of a WSL2 Ubuntu image e.g. the IP address of Eth0).

### CANoe Desktop Edition
Load the ``Bytestream.cfg`` from the ``./demos/CANoe`` directory and start the measurement.

Before doing this it makes sense to stop the AutoSender application first. Optionally you can also start the test unit execution of included test configuration. While the demo server is running the test should be successful. It sends "test message" through the toSocket topic, then receives it on the fromSocket one.

### CANoe4SW Server Edition (Windows)
You can also run the same test set with ``CANoe4SW SE`` by executing the following PowerShell script ``./demos/CANoe4SW_SE/run.ps1``. The test cases are executed automatically and you should see a short test report in PowerShell after execution.

### CANoe4SW Server Edition (Linux)
You can also run the same test set with CANoe4SW SE 19 SP3 or newer (Linux). In demos/CANoe4SW_SE/run.sh you should adapt `canoe4sw_se_install_dir` to the path of your CANoe4SW SE installation. Afterwards, you can execute demos/CANoe4SW_SE/run.sh. The CANoe4SW SE environment is created and test cases are executed automatically. You should see a short test report in your terminal after execution.

**Note:** CANoe4SW SE environment creation is only possible in Linux since CANoe4SW SE 19 SP3. If you are using an older version, first run the demos/CANoe4SW_SE/createEnvForLinux.ps1 Powershell script on your Windows system using the CANoe4SW SE (Windows) tools to set up the Linux test environment. Then, copy the `Default.venvironment` and `testBytestreamSocketEchoDemo.vtestunit` folders into the demos/CANoe4SW_SE directory on your Linux system. After that, you can execute the demos/CANoe4SW_SE/run.sh script.

## Using the SIL Kit Dashboard

For general instructions and features, see the documentation in [common/demos/README.md](https://github.com/vectorgrp/sil-kit-adapters-common/blob/main/docs/sil-kit-dashboard/README.md).

### Steps for the Demo

1. Start the SIL Kit registry with dashboard support:
    ```
    /path/to/SilKit-x.y.z-$platform/SilKit/bin/sil-kit-registry --listen-uri 'silkit://0.0.0.0:8501' --dashboard-uri http://localhost:8082
    ```

2. Launch the Byte Stream Socket adapter and demo participants as described above.

    > With SIL Kit Dashboard version 1.1.0 or newer, you can configure the participant configuration file to enable all available metrics. See the [SIL Kit documentation](https://github.com/vectorgrp/sil-kit/blob/main/docs/troubleshooting/advanced.rst) for details.

3. Open your web browser and navigate to [http://localhost:8080/dashboard](http://localhost:8080/dashboard).

4. In the dashboard, select the registry URI (e.g., `silkit://localhost:8501`).

5. In the participant tab, you should see `SilKitAdapterByteStreamSocket`, `ByteStreamSocketAutoSender`, and any other participants (such as CANoe).

6. Click on `SilKitAdapterByteStreamSocket` and look under `Data / RPC Services` to find the Data Publisher/Subscriber with the topic names `fromSocket` and `toSocket` and their labels.

7. Use the dashboard to monitor participant status and troubleshoot issues specific to the demo.
