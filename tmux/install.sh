#! /usr/bin/env bash
set -e
export DEBIAN_FRONTEND=noninteractive

# 1. Get Location
TMUX_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo ">>> Installing Tmux... (Source: $TMUX_DIR)"

# 2. Temp Dir Build
TEMP_DIR=$(mktemp -d)
pushd "$TEMP_DIR" > /dev/null

    # LIBEVENT
    echo ">>> Building Libevent..."
    wget -q https://github.com/libevent/libevent/releases/download/release-2.1.12-stable/libevent-2.1.12-stable.tar.gz
    tar -zxf libevent-*.tar.gz
    cd libevent-*/
    ./configure --prefix=$HOME/local --enable-shared --disable-static > /dev/null
    make -j$(nproc) > /dev/null && make install > /dev/null
    cd ..

    # NCURSES
    echo ">>> Building Ncurses..."
    wget -q https://invisible-island.net/datafiles/release/ncurses.tar.gz
    rm -rf ncurses-*/
    tar -zxf ncurses.tar.gz
    cd ncurses-*/
    ./configure --prefix=$HOME/local --with-shared --with-termlib --enable-pc-files --with-pkg-config-libdir=$HOME/local/lib/pkgconfig \
        --without-debug --without-ada --without-manpages --without-progs --without-tests > /dev/null
    make -j$(nproc) > /dev/null && make install > /dev/null
    cd ..

    # SYSTEM DEPS
    echo ">>> Installing System Deps..."
    sudo apt-get update -y -qq > /dev/null
    sudo apt-get install -y -qq \
        -o Dpkg::Options::="--force-confdef" \
        -o Dpkg::Options::="--force-confold" \
        libevent-dev ncurses-dev build-essential bison pkg-config > /dev/null

    # TMUX
    echo ">>> Building Tmux..."
    wget -q https://github.com/tmux/tmux/releases/download/3.6/tmux-3.6.tar.gz
    tar -zxf tmux-*.tar.gz
    cd tmux-*/
    PKG_CONFIG_PATH=$HOME/local/lib/pkgconfig ./configure --prefix=$HOME/local > /dev/null
    make -j$(nproc) > /dev/null && make install > /dev/null
    cd ..

# 3. Cleanup
popd > /dev/null
rm -rf "$TEMP_DIR"

# 4. Shell Config
if ! grep -q "export PATH=\$HOME/local/bin" ~/.bashrc; then
    echo ">>> Updating .bashrc..."
    cat <<EOF >> ~/.bashrc

# Custom Tmux Path
export PATH=\$HOME/local/bin:\$PATH
export LD_LIBRARY_PATH=\$HOME/local/lib:\$LD_LIBRARY_PATH
export MANPATH=\$HOME/local/share/man:\$MANPATH
EOF
fi

# 5. Autocomplete
if [ ! -f ~/.bash_completion ]; then
    curl -sL https://raw.githubusercontent.com/imomaliev/tmux-bash-completion/master/completions/tmux > ~/.bash_completion
fi

# 6. Linking
echo ">>> Linking Configs..."
ln -sf "$TMUX_DIR/.tmux.conf" "$HOME/.tmux.conf"

mkdir -p "$HOME/.local/bin"
ln -sf "$TMUX_DIR/restore.sh" "$HOME/.local/bin/tmux-restore"
ln -sf "$TMUX_DIR/save.sh"    "$HOME/.local/bin/tmux-save"
chmod +x "$TMUX_DIR/restore.sh" "$TMUX_DIR/save.sh"

echo ">>> Tmux Setup Complete!"

# Verify
if [ -x "$HOME/local/bin/tmux" ]; then
    "$HOME/local/bin/tmux" -V
fi

# Explicit success
exit 0
