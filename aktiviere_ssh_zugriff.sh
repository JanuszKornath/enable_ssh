#!/bin/bash

# Skript für openSUSE Tumbleweed – SSH-Zugriff dauerhaft ermöglichen

# Fehlerbehandlung
set -e

# Schritt 1: Netzwerkschnittstelle ermitteln
interface=$(nmcli device status | awk '$3 == "connected" {print $1}' | head -n1)

if [ -z "$interface" ]; then
  echo "❌ Keine aktive Netzwerkschnittstelle gefunden."
  exit 1
fi

echo "🌐 Verwendete Netzwerkschnittstelle: $interface"

# Schritt 2: Firewall-Zone auf 'work' setzen
echo "🛡 Setze Firewall-Zone der Schnittstelle $interface auf 'work'..."
sudo firewall-cmd --permanent --zone=work --change-interface=$interface

# Schritt 3: Port 22 und Dienst ssh in Zone 'work' freigeben
echo "🔓 Erlaube SSH in der Zone 'work'..."
sudo firewall-cmd --permanent --zone=work --add-service=ssh
# Alternativ (explizit Port 22, falls nötig):
# sudo firewall-cmd --permanent --zone=work --add-port=22/tcp

# Schritt 4: Firewall neu laden
echo "🔄 Lade Firewall neu..."
sudo firewall-cmd --reload

# Schritt 5: Sicherstellen, dass openssh installiert ist
if ! rpm -q openssh > /dev/null; then
  echo "📦 Installiere OpenSSH-Server..."
  sudo zypper install -y openssh
fi

# Schritt 6: SSH-Dienst aktivieren und starten
echo "🚀 Aktiviere und starte sshd..."
sudo systemctl enable sshd
sudo systemctl start sshd

# Schritt 7: Statusprüfung
sudo systemctl status sshd --no-pager

echo "✅ SSH-Zugriff ist nun dauerhaft eingerichtet."
