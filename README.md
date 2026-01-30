# USBDeviceInfo

Eine macOS-App zur Anzeige von Informationen über angeschlossene USB-Geräte.

## Funktionen

- Zeigt alle angeschlossenen USB-Geräte mit Vendor ID, Product ID und Seriennummer
- Generiert automatisch die **CrowdStrike Falcon Combined ID** zum einfachen Kopieren
- Speichert kürzlich verbundene Geräte in einer Historie
- Zeigt Host-Informationen (Computername, IP-Adressen, MAC-Adresse)
- Erkennt den CrowdStrike Falcon Sensor Status

### Falcon Device Control Erkennung

Wenn ein USB-Massenspeichergerät von **CrowdStrike Falcon Device Control** blockiert wird, zeigt die App ein oranges **"Blocked"**-Badge mit einem Schild-Symbol an.

Das Badge erscheint wenn:
1. Das Gerät ein Massenspeichergerät ist (z.B. USB-Stick, externe Festplatte)
2. Kein Volume gemountet werden konnte
3. Der Falcon Sensor als aktiv erkannt wurde

> **Hinweis:** Die Erkennung basiert auf Inferenz. Wenn ein Massenspeichergerät kein Volume hat und Falcon aktiv ist, wird angenommen dass Falcon das Gerät blockiert.

## Installation

### Download

Lade die neueste Version von der [Releases-Seite](https://github.com/dernerl/USBDeviceInfo/releases) herunter.

### Unsignierte App installieren

Da die App nicht mit einem Apple Developer Zertifikat signiert ist, blockiert macOS die Installation standardmäßig. So installierst du die App trotzdem:

**Methode 1: Rechtsklick**
1. Rechtsklick auf die `.pkg`-Datei
2. Wähle "Öffnen"
3. Klicke im Dialog auf "Öffnen"

**Methode 2: Systemeinstellungen**
1. Doppelklick auf die `.pkg`-Datei (wird blockiert)
2. Öffne **Systemeinstellungen** → **Datenschutz & Sicherheit**
3. Scrolle nach unten - dort erscheint eine Meldung über die blockierte App
4. Klicke auf "Trotzdem öffnen"

**Methode 3: Terminal**
```bash
# Quarantine-Attribut entfernen (Fehler "No such xattr" kann ignoriert werden)
xattr -d com.apple.quarantine ~/Downloads/USBDeviceInfo-*.pkg 2>/dev/null

# Dann normal per Doppelklick installieren
# Oder direkt via Terminal installieren:
sudo installer -pkg ~/Downloads/USBDeviceInfo-*.pkg -target /
```

## Lizenz

MIT
