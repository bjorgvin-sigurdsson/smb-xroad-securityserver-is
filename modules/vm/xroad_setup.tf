locals {
  vm_bash_script = <<CUSTOM_DATA
#!/bin/bash
mkdir -p /opt/xroad
cat <<SCRIPT_DATA > /opt/xroad/custom_script.sh
sudo useradd -c "X-Road admin user" -s /usr/sbin/nologin -M -p $(openssl passwd -1 "XROAD_WEBADMIN_PASSWORD") "xrd"
echo is_IS.UTF-8 | sudo tee -a /etc/environment > /dev/null

sudo apt-get install -y locales software-properties-common
sudo locale-gen is_IS.UTF-8
curl https://artifactory.niis.org/api/gpg/key/public | sudo apt-key add -
sudo apt-add-repository -y "deb https://artifactory.niis.org/xroad-release-deb $(lsb_release -sc)-current main"
sudo apt update -y

# Setup automatic reboots for security updates managed by unattended-upgrades
sudo apt-get -y install update-notifier-common
sudo sh -c 'echo "Unattended-Upgrade::Automatic-Reboot \"true\";" > /etc/apt/apt.conf.d/52unattended-upgrades-local'
sudo sh -c 'echo "Unattended-Upgrade::Automatic-Reboot-Time \"${var.automatic_update_reboot_time}\";" >> /etc/apt/apt.conf.d/52unattended-upgrades-local'
sudo systemctl restart unattended-upgrades

sudo apt install -y xroad-database-remote
# Create the file repository configuration:
sudo sh -c 'echo "deb https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

# Import the repository signing key:
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

# Update the package lists:
sudo apt-get -y update
sudo apt-get -y install postgresql-15

sudo touch /etc/xroad.properties
sudo chown root:root /etc/xroad.properties
sudo chmod 600 /etc/xroad.properties


echo "postgres.connection.user = postgres" | sudo tee -a /etc/xroad.properties > /dev/null
echo "postgres.connection.password = POSTGRESQL_PASSWORD" | sudo tee -a /etc/xroad.properties > /dev/null

# Created iirc using: sudo debconf-get-selections |grep 'xroad'
cat <<EOF >> preseed.cfg
d-i xroad-common/database-host string ${var.psql_fqdn}:5432
d-i xroad-common/service-subject string /C=IS/O=${var.organization}/CN=${azurerm_public_ip.pip.fqdn}
d-i xroad-common/proxy-ui-api-subject string /C=IS/O=${var.organization}/CN=${azurerm_public_ip.pip.fqdn}
d-i xroad-common/username string xrd
d-i xroad-common/service-altsubject string IP:${azurerm_public_ip.pip.ip_address},DNS:${azurerm_public_ip.pip.fqdn}
d-i xroad-common/proxy-ui-api-altsubject string IP:${azurerm_public_ip.pip.ip_address},DNS:${azurerm_public_ip.pip.fqdn}
EOF
sudo debconf-set-selections preseed.cfg
export DEBIAN_FRONTEND=noninteractive

sudo apt install -y xroad-securityserver-is

# sudo systemctl list-units "xroad-*"
SCRIPT_DATA
chmod +x /opt/xroad/custom_script.sh
CUSTOM_DATA
}