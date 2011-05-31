#!/bin/sh
set -e                          # exit on error

# this is a script to bootstrap kawauso
# requirements:
#    sbcl
#    clbuild
#    homebrew (if you are using Mac OS X)

function install_homebrew(){
    echo '\033[1;34m===> \033[1;0m installing homebrew'
    ruby -e "$(curl -fsSLk https://gist.github.com/raw/323731/install_homebrew.rb)"
}

function install_package() {
    local package OS
    OS=`uname`
    package=$1
    echo "\033[1;34m===> \033[1;0m installing $package"
    case $OS in
        Darwin)
            brew install $package
            ;;
        Linux)
            sudo apt-get install $package
    esac
}

# main
OS=`uname`
# setup package manager
case $OS in
    Darwin)
        if [ ! -e /usr/local/bin/brew ]; then
            install_homebrew
        fi
        ;;
esac

# setup sbcl
if [ ! -e "`which sbcl`" ]; then
    install_package "sbcl"
fi

# setup curl
if [ ! -e "`which curl`" ]; then
    install_package "curl"
fi

# run bootstrap script
sbcl --eval "$(curl -fsSLk https://github.com/garaemon/kawauso/raw/master/util/bootstrap.lisp)"
