#! /usr/bin/env bash

# get libevent
wget https://github.com/libevent/libevent/releases/download/release-2.1.12-stable/libevent-2.1.12-stable.tar.gz
tar -zxf libevent-*.tar.gz

cd libevent-*/
./configure --prefix=$HOME/local --enable-shared
make && make install

cd ..
rm -rf libevent-*/ libevent-*.tar.gz

# get ncurses
wget https://invisible-island.net/datafiles/release/ncurses.tar.gz

cd ncurses-*/
./configure --prefix=$HOME/local --with-shared --with-termlib --enable-pc-files --with-pkg-config-libdir=$HOME/local/lib/pkgconfig
make && make install

cd ..
rm -rf ncurses-*/ ncurses-*.tar.gz

# install other dep
sudo apt update -y
sudo apt install -y libevent-dev ncurses-dev build-essential bison pkg-config

# install tmux
wget https://github.com/tmux/tmux/releases/download/3.6/tmux-3.6.tar.gz
tar -zxf tmux-*.tar.gz

cd tmux-*/
PKG_CONFIG_PATH=$HOME/local/lib/pkgconfig ./configure --prefix=$HOME/local
make && make install

cd ..
rm -rf tmux-*/ tmux-*.tar.gz

# insert in .bashrc
cat <<EOF >> ~/.bashrc
export PATH=\$HOME/local/bin:\$PATH
export LD_LIBRARY_PATH=\$HOME/local/lib:\$LD_LIBRARY_PATH
export MANPATH=\$HOME/local/share/man:\$MANPATH
EOF

source ~/.bashrc
