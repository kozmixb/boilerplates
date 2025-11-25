/etc/pve/lxc/{LXC}.conf
```
lxc.cap.drop:
lxc.cgroup.devices.allow: c 10:232 rwm
lxc.mount.entry: /dev/kvm dev/kvm none bind,optional,create=file
```

lxc install.sh
```bash
#!/bin/bash

SDK_ROOT="$HOME/android-sdk"
TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-linux-13114758_latest.zip"
AVD_API_LEVEL="30"          # Target Android API Level (e.g., 30 for Android 11)
AVD_SYSTEM_IMAGE="x86_64"   # System image architecture (x86_64 required for KVM acceleration)
AVD_NAME="Headless_Test"

dpkg --add-architecture i386
apt update
apt install -y unzip wget default-jre-headless \
    libvirt-daemon libvirt-clients cpu-checker \
    libbz2-1.0 libxkbfile1 libncurses5:i386 libstdc++6:i386 lib32z1

mkdir -p "$SDK_ROOT/cmdline-tools/latest"
cd "$SDK_ROOT"

wget -O sdk-tools.zip "$TOOLS_URL"
unzip sdk-tools.zip
mv cmdline-tools latest
mkdir cmdline-tools
mv latest cmdline-tools/
rm sdk-tools.zip

grep -qxF 'export ANDROID_HOME="$HOME/android-sdk"' ~/.bashrc || \
    echo 'export ANDROID_HOME="$HOME/android-sdk"' >> ~/.bashrc
grep -qxF 'export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin"' ~/.bashrc || \
    echo 'export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin"' >> ~/.bashrc
grep -qxF 'export PATH="$PATH:$ANDROID_HOME/platform-tools"' ~/.bashrc || \
    echo 'export PATH="$PATH:$ANDROID_HOME/platform-tools"' >> ~/.bashrc

source ~/.bashrc

SDK_MANAGER="$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager"
AVD_MANAGER="$ANDROID_HOME/cmdline-tools/latest/bin/avdmanager"
PACKAGES="platform-tools emulator platforms;android-$AVD_API_LEVEL system-images;android-$AVD_API_LEVEL;default;$AVD_SYSTEM_IMAGE"

yes | "$SDK_MANAGER" --licenses
"$SDK_MANAGER" $PACKAGES

if ! groups | grep -q 'kvm'; then
    usermod -aG kvm "$USER"
    echo "⚠️ User '$USER' added to the 'kvm' group. Please log out and log back in after this script finishes!"
fi

echo no | "$AVD_MANAGER" create avd -n "$AVD_NAME" -k "system-images;android-$AVD_API_LEVEL;default;$AVD_SYSTEM_IMAGE"
echo "--- ✅ Android SDK Setup Complete! ---"
echo "You can now launch your emulator instance with a unique port and in headless mode:"
echo "emulator -avd $AVD_NAME -no-window -port 5554 &"
```


lxc run.sh
```bash
#!/bin/bash

EMULATOR_BIN="$ANDROID_HOME/emulator/emulator"
AVD_NAME="Headless_Test"
BASE_PORT="5554"
echo "---  ^=^s  Starting Android Emulator '$AVD_NAME' on port $BASE_PORT ---"
if [ ! -f "$EMULATOR_BIN" ]; then
    echo " ^}^l Error: Emulator binary not found at $EMULATOR_BIN."
    echo "   Ensure you installed the 'emulator' package using sdkmanager."
    exit 1
fi

if [ ! -d "$HOME/.android/avd/$AVD_NAME.avd" ]; then
    echo " ^}^l Error: AVD '$AVD_NAME' not found."
    echo "   Ensure you created this AVD using avdmanager."
    exit 1
fi

"$EMULATOR_BIN" -avd "$AVD_NAME" \
    -no-window \
    -port "$BASE_PORT" \
    -gpu off \
    -qemu -monitor none \
    -no-snapshot-save &

sleep 2

ADB_PORT=$((BASE_PORT + 1))
EMU_PID=$(jobs -p | tail -1)

echo "---  ^|^e Emulator Started ---"
echo "AVD Name:      $AVD_NAME"
echo "Console Port:  $BASE_PORT"
echo "ADB Port:      $ADB_PORT (Emulator device name: emulator-$ADB_PORT)"
echo "Process ID:    $EMU_PID"
echo ""
echo "To connect to this device from your local machine, set up an SSH tunnel:"
echo "   ssh -N -L 6001:localhost:$ADB_PORT user@your.server.ip"
echo "Then, connect locally:"
echo "   adb connect localhost:6001"
```
