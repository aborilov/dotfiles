# Read by every zsh, including the non-interactive ones VS Code Remote-SSH and
# ssh commands start, so the real Go toolchain wins over Ubuntu's golang-1.18.
export PATH=/usr/local/go/bin:$HOME/bin:$HOME/.local/bin:$HOME/go/bin:/usr/local/bin:$PATH
