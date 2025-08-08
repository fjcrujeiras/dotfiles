#!/bin/bash

#set -e

export HOST=$(hostname)

for file in ./group/${HOST}/*; do
	echo "Installing $file"
	sudo pacman -S --asexplicit --noconfirm - < "$file"
	paru -S --asexplicit --needed --noconfirm - < "$file"
done
