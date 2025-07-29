Das Bash-Skript richtet auf openSUSE Tumbleweed den dauerhaften SSH-Zugriff ein, und ist sowohl mit NetworkManager als auch mit Wicked kompatibel.

Funktionen des Skripts:

- Netzwerk-Schnittstelle automatisch erkennen, je nach aktivem Netzwerkdienst.
- Firewall-Konfiguration.
- Schnittstelle einer Firewallzone zuordnen.
- OpenSSH-Paket installieren, falls nicht vorhanden.
- SSH-Dienst aktivieren & starten.
