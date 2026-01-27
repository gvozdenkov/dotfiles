#! /usr/bin/env bash
set -e

DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo ">>> Linking Core Dotfiles from $DOTFILES_DIR..."

ln -sf "$DOTFILES_DIR/.vimrc" "$HOME/.vimrc"
ln -sf "$DOTFILES_DIR/.bashrc" "$HOME/.bashrc"
ln -sf "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
ln -sf "$DOTFILES_DIR/.terraformrc" "$HOME/.terraformrc"

echo ">>> Setting up Tmux..."
# Run the script and capture its exit code
# We explicitly allow failure momentarily (set +e) to handle the error ourselves
set +e
bash "$DOTFILES_DIR/tmux/install.sh"
TMUX_EXIT_CODE=$?
set -e

# Check if it succeeded
if [ $TMUX_EXIT_CODE -eq 0 ]; then
    echo ">>> Tmux setup finished successfully."
else
    echo "!!! Tmux setup FAILED with exit code $TMUX_EXIT_CODE"
    # Decide if you want to fail the whole dotfiles install or just warn
    # exit $TMUX_EXIT_CODE  <-- Uncomment to fail hard
    echo "!!! Continuing with remaining dotfiles..."
fi

echo ">>> Dotfiles Installation Complete!"

# Ensure buffer flush
sleep 1
exit 0