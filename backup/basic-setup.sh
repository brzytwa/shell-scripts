#!/bin/bash

# basic configuration of a clean system installation

echo "Installation of necessary packages"
sudo dnf -y install vim mc tmux htop bash-completion fish util-linux-user fzf fontconfig git gh NetworkManager-tui 

echo "Configuration of tmux software"
mkdir -pv ~/.config/tmux && echo "setw -g mouse on" >> ~/.config/tmux/tmux.conf 

cat <<EOT>> ~/.bashrc  
# Włącz bash-completion
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
elif [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
fi

# Enable more advanced completion only in interactive mode
if [[ $- == *i* ]]; then
    bind "set show-all-if-ambiguous on"
    bind "set completion-ignore-case on"
    bind "set menu-complete-display-prefix on"
    bind "set colored-stats on"
    bind "set colored-completion-prefix on"
fi

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# History configuration
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoreboth
shopt -s histappend
EOT

echo "Installation and configuration of starship and fish"

curl -sS https://starship.rs/install.sh | sh
echo 'eval "$(starship init bash)"' >> ~/.bashrc

chsh -s $(which fish)
mkdir -p ~/.config/fish
cat > ~/.config/fish/config.fish << 'EOT'
if status is-interactive
    # Commands to run in interactive sessions can go here
    starship init fish | source
end
EOT
