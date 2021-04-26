Hand Tracker
============

![screenshot](doc/screenshot.png)

An ofxTensorFlow2 example using the Google Mediapipe Hand Tracking model as converted to TF2 from the following GitHub repo:

https://github.com/geaxgx/depthai_hand_tracker

Dependencies
------------

* [openFrameworks](https://openframeworks.cc/download/)
* openFrameworks addons:
  - ofxOSC (included with oF)
  - [ofxTensorFlow2](https://github.com/zkmkarlsruhe/ofxTensorFlow2)
* Pre-trained hand tracker model placed in `bin/data`

Installation & Build
--------------------

Overview:

1. Follow the steps in the ofxTensorFlow2 "Installation & Build" section for you platform
2. Download the pre-trained model and place it in `HandTracker/bin/data`
2. Generate the project files for this folder using the OF ProjectGenerator
3. Build for your platform

### Downloading Pre-Trained Model

A version of the pre-trained model converted to TensorFlow2 is provided which you cna download as `model_hancktracking.zip` from a public shared link here:

https://cloud.zkm.de/index.php/s/gfWEjyEr9X4gyY6

After unzippiong the file, place the SavedModel folder named "model" in `HandTracker/bin/data/`.

To make this quick, a script is provided to download and install the model (requires a Unix shell, curl, and unzip):

```shell
cd HandTracker
./scripts/download_model.sh
```

### Generating Project Files

Project files are not included so you will need to generate the project files for your operating system and development environment using the OF ProjectGenerator which is included with the openFrameworks distribution.

To (re)generate project files for an existing project:

1. Click the "Import" button in the ProjectGenerator
2. Navigate to the project's parent folder ie. "apps/myApps", select the base folder for the example project ie. "HandTracker", and click the Open button
3. Click the "Update" button

If everything went Ok, you should now be able to open the generated project and build/run the example.

### macOS

Open the Xcode project, select the "HandTracker Debug" scheme, and hit "Run".

For a Makefile build, build and run an example on the terminal:

```shell
cd HandTracker
make ReleaseTF2
make RunRelease
```
### Linux

For a Makefile build, build and run an example on the terminal:

```shell
cd HandTracker
make Release
make RunReleaseTF2
```

Usage
-----

The openFrameworks application runs the tracker model using webcam input. The tracked hand output is mapped to several parameters which are normalized and sent out using OSC.

Sends to:
* Address: `localhost` ie. `127.0.0.1`
* Port: `9999`

Message specification:

* /detected f: detection event, bool 1 found - 0 lost
* /pinch f: relative pinch between thumb and middle fingertips, float 0 far - 1 close

Demos
-----

*Info to be added.*
