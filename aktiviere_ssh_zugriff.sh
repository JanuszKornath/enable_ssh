#!/bin/bash

#Skript für openSUSE Tumbleweed um den SSH-Zugriff dauerhaft ermöglichen
#jetzt kompatibel mit NetworkManager & Wicked

#Fehlerbehandlung
set -e

echo "=== SSH-Zugriff einrichten ==="

#Netzwerkschnittstelle ermitteln
echo "Ermittle aktive Netzwerkschnittstelle..."

interface=""

if systemctl is-active --quiet NetworkManager; then
    echo "➡ NetworkManager aktiv – verwende nmcli..."
    interface=$(nmcli device status | awk '$3 == "connected" && $1 != "lo" {print $1}' | head -n1)
fi
#Wenn nichts gefunden → Wicked (oder IP-Fallback)
if [ -z "$interface" ]; then
    echo "➡ Versuche Wicked (ip/ifstatus)..."
    interface=$(ip -o -4 addr show up | awk '$2 != "lo" {print $2}' | head -n1)
fi

if [ -z "$interface" ]; then
    echo "Keine aktive Netzwerkschnittstelle gefunden."
    exit 1
fi

echo "Verwendete Netzwerkschnittstelle: $interface"

#Firewall-Zone auf 'work' setzen
echo "Setze Firewall-Zone der Schnittstelle $interface auf 'work'..."
sudo firewall-cmd --permanent --zone=work --change-interface=$interface

#Dienst ssh in Zone 'work' freigeben
echo "Erlaube SSH in der Zone 'work'..."
sudo firewall-cmd --permanent --zone=work --add-service=ssh
#Alternativ (explizit Port 22, falls nötig):
#sudo firewall-cmd --permanent --zone=work --add-port=22/tcp

#Firewall neu laden
echo "Lade Firewall neu..."
sudo firewall-cmd --reload

#Sicherstellen, dass OpenSSH installiert ist
if ! rpm -q openssh > /dev/null; then
  echo "Installiere OpenSSH-Server..."
  sudo zypper install -y openssh
fi

#SSH-Dienst aktivieren und starten
echo "Aktiviere und starte sshd..."
sudo systemctl enable sshd
sudo systemctl start sshd || {
    echo "Fehler beim Start von sshd."
    echo "Details: sudo journalctl -xeu sshd"
    exit 1
}

#Statusprüfung
sudo systemctl status sshd --no-pager

echo "SSH-Zugriff ist nun dauerhaft eingerichtet."
