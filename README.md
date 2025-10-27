# My Dotfiles

This repository works as a way of quicken up the process of configuring a PC from a fresh install, reducing the downtime and keeping a consistent workflow between my multiple machines.

## Table of Contents

<!-- toc -->

- [Requirements](#requirements)
- [How do I use it?](#how-do-i-use-it)
- [Sway dependencies (DEPRECATED)](#sway-dependencies-deprecated)
  * [Permissions for the **light** command](#permissions-for-the-light-command)
- [Launch wofi](#launch-wofi)

<!-- tocstop -->

## Requirements

[!NOTE]
> This repository assumes that you are running an Arch-based distro (precisely [Omarchy](https://omarchy.org)).

* Install all the needed packages:

```bash
./packages/install.sh
```

## How do I use it?

1. Clone the repository in ~/dotfiles
2. cd to the ~/dotfiles directory
3. Execute:
```bash
stow --dotfiles dot-config
```
```
```
4. Enjoy :-D.

## Sway dependencies (DEPRECATED)

```bash
sudo apt install -y light sway swaybg swayidle swayimg swaylock waybar wofi fonts-font-awesome clipman
```
### Permissions for the **light** command

In order to use the light command without sudo, the current user must be part of the *video* group

```bash
sudo usermod -aG video $USER
```

## Launch wofi

```bash

```
