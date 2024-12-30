# ResportCode Flutter App

App aiming to create a community for re-using sports equipment.

---

## Prerequisites

Before running the project, ensure you have the following installed:

1. **Flutter SDK**:
   - Install Flutter from [Flutter Installation Guide](https://flutter.dev/docs/get-started/install).
   - Run `flutter doctor` in your terminal to verify your Flutter setup.

2. **Xcode**:
   - Download Xcode from the Mac App Store.
   - Open Xcode, agree to the license agreement, and install any necessary components.

3. **IntelliJ IDEA** or any IDE with Flutter support:
   - Install IntelliJ IDEA (Community or Ultimate).
   - Go to **Settings > Plugins** and install both the **Flutter** and **Dart** plugins.

4. **iOS Simulator** or a Physical iPhone:
   - Ensure you have access to an iOS Simulator or a connected iPhone.

---

## Setup Instructions

### Step 1: Clone the Repository
Clone the repository to your local machine:
```bash
git clone <repository-url>
cd resportcode
```

### Step 2: Install Dependencies
Fetch all the required packages
```bash
flutter pug get
```
### Step 3: Running Resport
To check devices to run on use:
```bash
flutter devices
```
This will show all simulators, wired, or wireless devices you can connect to.
Take note of the device-ID of the device you want to run the app on. To run the app use:
```bash
flutter run -d <INSERT_DEVICE_ID>
```

### Step 4: Use Aliases
To avoid typing the device-ID each time, create aliases for the commands by adding the following to your shell config:
```bash
alias flutter-<DEVICE>='flutter run -d <INSERT_DEVICE_ID>'
```
To edit your configuration open the config using:
```bash
nano ~/.zshrc
```
OR
```bash
nano ~/.bashrc
```
And to save and reload the configuration, replace nano with source


### Additional Commands
Rebuild the project:
```bash
flutter clean
```
Run Resport on All Devices
```bash
flutter run
```
Opening XCode Simulation
```bash
open -a simulator
```

