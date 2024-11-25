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
echo "4. Stop BlockMesh"
echo "5. Update BlockMesh"
read -p "Enter action number: " ACTION

# Define the current user and home directory
USERNAME=$(whoami)
HOME_DIR=$(eval echo ~$USERNAME)

case $ACTION in
    1)
        echo "Installing BlockMesh node"
        
        # Check for tar command and install it if not found
        if ! command -v tar &> /dev/null; then
            sudo apt install tar -y
        fi
        sleep 1
        
        # Загружаем и исполняем скрипт для получения последней версии BlockMesh
        VERSION_URL=$(bash <(curl -s https://raw.githubusercontent.com/dvorakkk/BlockMeshGuide/refs/heads/main/version.sh))

        # Загружаем бинарник BlockMesh
        wget $VERSION_URL

        # Extract the archive
        tar -xzvf blockmesh-cli-x86_64-unknown-linux-gnu.tar.gz
        sleep 1

        # Remove the archive
        rm blockmesh-cli-x86_64-unknown-linux-gnu.tar.gz

        # Navigate to the node folder
        cd target/x86_64-unknown-linux-gnu/release/

        # Prompt user for input
        echo "Enter your email:"
        read USER_EMAIL

        echo "Enter your password:"
        read -s USER_PASSWORD

        # Create or update the service file
        sudo bash -c "cat <<EOT > /etc/systemd/system/blockmesh.service
[Unit]
Description=BlockMesh CLI Service
After=network.target

[Service]
User=$USERNAME
ExecStart=$HOME_DIR/target/x86_64-unknown-linux-gnu/release/blockmesh-cli login --email $USER_EMAIL --password $USER_PASSWORD
WorkingDirectory=$HOME_DIR/target/x86_64-unknown-linux-gnu/release
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
    4)
        # Stop BlockMesh
        echo "Stopping BlockMesh"
        sudo systemctl stop blockmesh
        echo "BlockMesh service stopped"
        ;;
    5)
        echo "Updating BlockMesh node..."

        # Stop and disable the service
        sudo systemctl stop blockmesh
        sudo systemctl disable blockmesh
        sudo rm /etc/systemd/system/blockmesh.service
        sudo systemctl daemon-reload
        sleep 1

        # Remove old node files
        rm -rf target
        sleep 1

        # Получаем ссылку на последнюю версию через version.sh
        VERSION_URL=$(bash <(curl -s https://raw.githubusercontent.com/dvorakkk/BlockMeshGuide/refs/heads/main/version.sh))

        # Загружаем бинарник новой версии
        wget $VERSION_URL

        # Extract the archive
        tar -xzvf blockmesh-cli-x86_64-unknown-linux-gnu.tar.gz
        sleep 1

        # Remove the archive
        rm blockmesh-cli-x86_64-unknown-linux-gnu.tar.gz

        # Navigate to the release folder
        cd target/x86_64-unknown-linux-gnu/release/

        # Prompt user for input to update variables
        echo "Enter your email for BlockMesh:"
        read USER_EMAIL
        echo "Enter your password for BlockMesh:"
        read -s USER_PASSWORD

        # Create or update the service file
        sudo bash -c "cat <<EOT > /etc/systemd/system/blockmesh.service
[Unit]
Description=BlockMesh CLI Service
After=network.target

[Service]
User=$USERNAME
ExecStart=$HOME_DIR/target/x86_64-unknown-linux-gnu/release/blockmesh-cli login --email $USER_EMAIL --password $USER_PASSWORD
WorkingDirectory=$HOME_DIR/target/x86_64-unknown-linux-gnu/release
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOT"

        # Restart the service
        sudo systemctl daemon-reload
        sleep 1
        sudo systemctl enable blockmesh
        sudo systemctl restart blockmesh

        # Final output
        echo "Update completed, and node is running!"
        ;;
    *)
        echo "Invalid selection, exiting..."
        ;;
esac
