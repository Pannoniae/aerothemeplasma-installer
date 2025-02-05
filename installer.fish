#!/usr/bin/fish

# AeroThemePlasma Installation Script

# Determine the real user who invoked sudo
set REAL_USER (logname)
set HOME (getent passwd $REAL_USER | cut -d: -f6)

# Check if running with sufficient privileges
if not test (id -u) -eq 0
    echo "This script must be run with sudo or as root."
    exit 1
end

function check_folder
    if not test -d kwin
        echo "AeroThemePlasma not found in the current folder."
        exit 1
    end
end

# Detect Linux distribution
function detect_distro
    if test -f /etc/arch-release
        echo "arch"
    else if test -f /etc/fedora-release
        echo "fedora"
    else if test -f /etc/debian_version
        echo "debian"
    else
        echo "unsupported"
    end
end

# Install prerequisites based on distribution
function install_prerequisites
    set -l distro (detect_distro)
    switch $distro
        case "arch"
            sudo pacman -S --noconfirm --needed cmake extra-cmake-modules ninja qt6-virtualkeyboard qt6-multimedia qt6-5compat plasma-wayland-protocols plasma5support kvantum plymouth
        case "debian"
            sudo apt install -y cmake extra-cmake-modules ninja-dev qt6-virtualkeyboard qt6-virtualkeyboard-dev qt6-multimedia qt6-multimedia-dev qt6-5compat plasma-wayland-protocols kf6-plasma5support kf6-kcolorscheme-dev kf6-ki18n-dev kf6-kiconthemes-dev kf6-kcmutils-dev kf6-kirigami-dev libkdecorations2-dev kwin-dev kf6-kio-dev kf6-knotifications-dev kf6-ksvg-dev plasma-workspace-dev kf6-kactivities-dev gettext kvantum plymouth
        case "fedora"
            sudo dnf install -y plasma-workspace-devel kvantum qt6-qtmultimedia-devel qt6-qt5compat-devel libplasma-devel qt6-qtbase-devel qt6-qtwayland-devel plasma-activities-devel kf6-kpackage-devel kf6-kglobalaccel-devel qt6-qtsvg-devel wayland-devel plasma-wayland-protocols kf6-ksvg-devel kf6-kcrash-devel kf6-kguiaddons-devel kf6-kcmutils-devel kf6-kio-devel kdecoration-devel kf6-ki18n-devel kf6-knotifications-dev kf6-kirigami-devel kf6-kiconthemes-devel cmake
        case "*"
            echo "Unsupported distribution. Please install prerequisites manually."
            exit 1
    end
end

# Clone the repository
function clone_repository
    git clone https://gitgud.io/wackyideas/aerothemeplasma.git aerothemeplasma
    cd aerothemeplasma
end

# Install Plasma components
function install_plasma_components
    # Install smod resources
    mkdir -p $HOME/.local/share
    cp -r plasma/smod $HOME/.local/share/

    # Install Plasma-related folders
    mkdir -p $HOME/.local/share/plasma
    cp -r plasma/desktoptheme plasma/look-and-feel plasma/plasmoids plasma/shells plasma/layout-templates $HOME/.local/share/plasma/
    #cp -r plasma/look-and-feel plasma/plasmoids plasma/shells $HOME/.local/share/plasma/

    # Install SDDM theme
    sudo cp -r plasma/sddm/sddm-theme-mod /usr/share/sddm/themes/
    pushd /usr/share/sddm/themes/sddm-theme-mod/Services
    sudo chmod +x install-services.sh
    sudo ./install-services.sh
    popd
end

# Install KWin components
function install_kwin_components

    # Compile important components
    chmod +x compile.sh
    ./compile.sh

    # Install KWin-related folders
    mkdir -p $HOME/.local/share/kwin
    cp -r kwin/effects kwin/tabbox kwin/outline kwin/scripts $HOME/.local/share/kwin/
end

# Install miscellaneous components
function install_misc_components
    # Install default tooltip
    if test -f misc/defaulttooltip/install.sh
        pushd misc/defaulttooltip
        chmod +x install.sh
        ./install.sh
        popd
    end

    # Install Kvantum theme
    cp -r misc/kvantum/Kvantum $HOME/.config/

    # Install sounds
    mkdir -p $HOME/.local/share/sounds
    tar -xf misc/sounds/sounds.tar.gz -C $HOME/.local/share/sounds

    # Install icons
    mkdir -p $HOME/.local/share/icons
    tar -xf "misc/icons/Windows 7 Aero.tar.gz" -C $HOME/.local/share/icons

    # Install cursor theme
    sudo tar -xf misc/cursors/aero-drop.tar.gz -C /usr/share/icons

    # Install mimetypes
    mkdir -p $HOME/.local/share/mime/packages
    cp misc/mimetype/* $HOME/.local/share/mime/packages/
    update-mime-database $HOME/.local/share/mime

    # Optional: Configure font hinting
    cp -r misc/fontconfig $HOME/.config/
end

# Main installation function
function main
    install_prerequisites
    clone_repository

    check_folder

    # Install components
    install_plasma_components
    install_kwin_components
    install_misc_components

    echo "AeroThemePlasma installation complete!"
    echo "Please configure KDE Plasma settings as described in the installation guide."
end

main
