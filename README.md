# My Dotfiles

This repository works as a way of keeping consistency in my work tools through different machines.

## Requirements

This works due to **GNU Stow**:

```shell
sudo apt install stow
sudo dnf install stow
```

## How do I use it?

1. Clone the repository in ~/dotfiles
2. cd to the ~/dotfiles directory
3. Execute `stow <configStructure>`. This will create symlinks, keeping the folder structure defined in the dotfiles directory.
4. Enjoy :-D.
