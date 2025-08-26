
#!/bin/bash


#  ███████╗██╗   ██╗██████╗  ██████╗  ██████╗     ███╗   ███╗ █████╗ ██╗  ██╗███████╗
#  ██╔════╝██║   ██║██╔══██╗██╔═══██╗██╔═══██╗    ████╗ ████║██╔══██╗██║ ██╔╝██╔════╝
#  ███████╗██║   ██║██████╔╝██║   ██║██║   ██║    ██╔████╔██║███████║█████╔╝ ███████╗
#  ╚════██║██║   ██║██╔══██╗██║   ██║██║   ██║    ██║╚██╔╝██║██╔══██║██╔═██╗ ╚════██║
#  ███████║╚██████╔╝██████╔╝╚██████╔╝╚██████╔╝    ██║ ╚═╝ ██║██║  ██║██║  ██╗███████║
#  ╚══════╝ ╚═════╝ ╚═════╝  ╚═════╝  ╚═════╝     ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝
#
#  Modular Linux Bootstrapper
#  Author: psycho
#  Repo: https://github.com/kalchan12/sudo-make-me-a-sandwich-
#

# Source core utilities (add more as needed)
source core/utils.sh 2>/dev/null || true
source core/distro_detect.sh 2>/dev/null || true

# Main menu function: shows categories
show_main_menu() {

	echo "1) Browsers"
	echo "2) Editors"
	echo "3) Note Taking"
	echo "4) Exit"
	echo -n "Select a category: "
	read -r category
	case $category in
		1) show_browsers_menu ;;
		2) show_editors_menu ;;
		3) show_note_menu ;;
		4) show_banner_footer; exit 0 ;;
		*) echo "Invalid option"; show_main_menu ;;
	esac
}

# Browsers submenu
show_browsers_menu() {
	echo "\n-- Browsers --"
	echo "1) Firefox"
	echo "2) Brave"
	echo "3) Chrome"
	echo "4) Vivaldi"
	echo "5) Back"
	echo -n "Select browser(s) to install (comma-separated, e.g. 1,3): "
	read -r browsers
	for b in $(echo $browsers | tr ',' ' '); do
		case $b in
			1) echo "Installing Firefox..." ;; # ./modules/install_firefox.sh
			2) echo "Installing Brave..." ;; # ./modules/install_brave.sh
			3) echo "Installing Chrome..." ;; # ./modules/install_chrome.sh
			4) echo "Installing Vivaldi..." ;; # ./modules/install_vivaldi.sh
			5) show_main_menu; return ;;
			*) echo "Invalid option: $b" ;;
		esac
	done
	show_main_menu
}

# Editors submenu
show_editors_menu() {
	echo "\n-- Editors --"
	echo "1) VS Code"
	echo "2) NeoVim"
	echo "3) Atom"
	echo "4) Back"
	echo -n "Select editor(s) to install (comma-separated, e.g. 1,2): "
	read -r editors
	for e in $(echo $editors | tr ',' ' '); do
		case $e in
			1) echo "Installing VS Code..." ;; # ./modules/install_vscode.sh
			2) echo "Installing NeoVim..." ;; # ./modules/install_neovim.sh
			3) echo "Installing Atom..." ;; # ./modules/install_atom.sh
			4) show_main_menu; return ;;
			*) echo "Invalid option: $e" ;;
		esac
	done
	show_main_menu
}

# Note Taking submenu
show_note_menu() {
	echo "\n-- Note Taking --"
	echo "1) Obsidian"
	echo "2) Back"
	echo -n "Select note app(s) to install (comma-separated, e.g. 1): "
	read -r notes
	for n in $(echo $notes | tr ',' ' '); do
		case $n in
			1) echo "Installing Obsidian..." ;; # ./modules/install_obsidian.sh
			2) show_main_menu; return ;;
			*) echo "Invalid option: $n" ;;
		esac
	done
	show_main_menu
}

# Banner/footer function
show_banner_footer() {
	echo "\n============================================="
	echo "  Thank you for using sudo-make-me-a-sandwich!"
	echo "  Author: psycho"
	echo "============================================="
}

# Start the menu
show_main_menu
