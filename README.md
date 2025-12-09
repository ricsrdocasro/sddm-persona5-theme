# Persona 5 SDDM Theme
### "Take Your Time"

A fully animated, kinetic login theme for SDDM (Simple Desktop Display Manager) inspired by the UI of **Persona 5**.

![Preview](output.gif)

## 🎩 Features

* **Kinetic Login Animation:** A dagger flies in and pierces the "Press Any Button" prompt upon hitting Enter.
* **Animated Logo:** The Phantom Thieves hat features a frame-by-frame fire animation loop.
* **Sprite-Based Clock:** The date and time are rendered using individual cut-out sprites, replicating the jagged calendar system from the game.
* **Reactive UI:** The interface shakes violently upon an incorrect password entry ("Access Denied" effect).
* **4K Ready:** Includes auto-scaling logic (`scaleFactor`) to look crisp on 1080p, 1440p, and 4K monitors.
* **Immersive Typography:** Uses **p5hatty** and **Arsenal** fonts (loaded locally) for an authentic look.

## 📦 Requirements

* **SDDM** (Simple Desktop Display Manager)
* **Qt5** (qt5-quickcontrols2, qt5-graphicaleffects)
* *Note: This theme should work on most Linux distributions (Arch, Fedora, Debian, etc.) using KDE Plasma or Hyprland.*

## ⬇️ Installation

### Option 1: Automatic Script (Recommended)
This repository includes an installation script that handles copying files, setting permissions, and updating your config automatically.

1.  **Clone the Repository:**
    ```bash
    git clone [https://github.com/YOUR_USERNAME/persona5-sddm-theme.git](https://github.com/YOUR_USERNAME/persona5-sddm-theme.git)
    cd persona5-sddm-theme
    ```

2.  **Run the Installer:**
    ```bash
    chmod +x install.sh
    sudo ./install.sh
    ```

3.  **Test It:**
    You can preview the theme without logging out:
    ```bash
    sddm-greeter --test-mode --theme /usr/share/sddm/themes/persona5
    ```

---

### Option 2: Manual Installation
If you prefer to move files yourself:

1.  **Move to Themes Directory:**
    ```bash
    sudo mkdir -p /usr/share/sddm/themes/persona5
    sudo cp -r * /usr/share/sddm/themes/persona5/
    ```

2.  **Configure SDDM:**
    Edit your SDDM configuration file:
    ```bash
    sudo nano /etc/sddm.conf
    # OR: sudo nano /etc/sddm.conf.d/theme.conf.user
    ```

    Find the `[Theme]` section and set:
    ```ini
    [Theme]
    Current=persona5
    ```

## 🔧 Configuration

### Changing the Wallpaper
To use your own wallpaper, replace the `background.png` file in the theme folder:

```bash
sudo cp /path/to/your/image.png /usr/share/sddm/themes/persona5/background.png
