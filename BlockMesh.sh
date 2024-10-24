#!/bin/bash

# Node Mafia ASCII Art
echo "
     __             _                        __  _        
  /\ \ \  ___    __| |  ___   /\/\    __ _  / _|(_)  __ _ 
 /  \/ / / _ \  / _\` | / _ \ /    \  / _\` || |_ | | / _\` |
/ /\  / | (_) || (_| ||  __// /\/\ \| (_| ||  _|| || (_| |
\_\ \/   \___/  \__,_| \___|\/    \/ \__,_||_|  |_| \__,_|
                                                          
EN Telegram: soon..
RU Telegram: https://t.me/nodemafia
GitHub: https://github.com/NodeMafia
Medium: https://medium.com/@nodemafia
Teletype: https://teletype.in/@nodemafia
Twitter: https://x.com/NodeMafia
"

# Menu selection
echo "Choose an action:"
echo "1. Install BlockMesh"
echo "2. View logs"
echo "3. Delete BlockMesh node"
read -p "Enter action number: " ACTION

case $ACTION in
    1)
        echo "Installing BlockMesh node"
        
        # Check for tar command and install it if not found
        if ! command -v tar &> /dev/null; then
            sudo apt install tar -y
        fi
        sleep 1
        
        # Download the BlockMesh binary
        wget https://github.com/block-mesh/block-mesh-monorepo/releases/download/v0.0.307/blockmesh-cli-x86_64-unknown-linux-gnu.tar.gz
        
        # Extract the archive
        tar -xzvf blockmesh-cli-x86_64-unknown-linux-gnu.tar.gz
        sleep 1

        # Remove the archive
        rm blockmesh-cli-x86_64-unknown-linux-gnu.tar.gz

        # Navigate to the node folder
        cd target/release

        # Prompt user for input
        echo -e "\e[31mEnter your email:\e[0m"
        read USER_EMAIL

        echo -e "\e[31mEnter your password:\e[0m"
        read -s USER_PASSWORD

        # Determine the current username and home directory
        USERNAME=$(whoami)

        if [ "$USERNAME" == "root" ]; then
            HOME_DIR="/root"
        else
            HOME_DIR="/home/$USERNAME"
        fi

        # Create or update the service file using the detected username and home directory
        sudo bash -c "cat <<EOT > /etc/systemd/system/blockmesh.service
[Unit]
Description=BlockMesh CLI Service
After=network.target

[Service]
User=$USERNAME
ExecStart=$HOME_DIR/target/release/blockmesh-cli login --email $USER_EMAIL --password $USER_PASSWORD
WorkingDirectory=$HOME_DIR/target/release
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOT"

        # Reload systemd services and enable BlockMesh service
        sudo systemctl daemon-reload
        sleep 1
        sudo systemctl enable blockmesh
        sudo systemctl start blockmesh

        # Final output
        echo "Installation completed successfully"
        ;;
    2)
        # View BlockMesh logs
        echo "Viewing BlockMesh logs"
        sudo journalctl -u blockmesh -f
        ;;
    3)
        # Delete BlockMesh node
        echo "Deleting BlockMesh node"
        sudo systemctl stop blockmesh
        sudo systemctl disable blockmesh
        sudo rm /etc/systemd/system/blockmesh.service
        sudo systemctl daemon-reload
        rm -rf target
        echo "BlockMesh node deleted"
        ;;
    *)
        echo "Invalid selection, exiting..."
        ;;
esac
