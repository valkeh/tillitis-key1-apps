# Test loop

To add a shortcut icon for the TK-1 test loop to the Gnome launch menu:

	desktop-file-install --dir=$HOME/.local/share/applications tk1.desktop
	update-desktop-database ~/.local/share/applications
	gsettings set org.gnome.shell favorite-apps "['firefox_firefox.desktop', 'org.gnome.Nautilus.desktop', 'tk1.desktop']"

Afterwards, the test application can be launched by clicking on the icon on the left side of the screen.
