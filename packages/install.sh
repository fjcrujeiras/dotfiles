#!/bin/bash

#set -e

export HOST=$(hostname)

for file in ./group/${HOST}/*; do
	echo "Installing $file"
	sudo pacman -S --asexplicit --noconfirm - < "$file"
	yay -S --asexplicit --needed --noconfirm - < "$file"
done
