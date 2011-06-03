#!/bin/sh
set -e                          # exit on error

# this is a script to bootstrap kawauso
# requirements:
#    sbcl
#    homebrew (if you are using Mac OS X)

function color_echo() {
    echo "\033[1;34m===> \033[1;0m $@"
}

function install_homebrew() {
    color_echo "installing homebrew"
    ruby -e "$(curl -fsSLk https://gist.github.com/raw/323731/install_homebrew.rb)"
}

function install_package() {
    local package OS
    OS=`uname`
    package=$1
    if [ ! -e "`which $package`" ]; then
        color_echo "installing $package"
        case $OS in
            Darwin)
                brew install $package
                ;;
            Linux)
                sudo apt-get install $package
                ;;
        esac
    fi
}

function update_asdf() {
    color_echo installing asdfs
    mkdir -p $root_dir/kawauso/systems
    find $1 -name "*.asd" -exec ln -sf {} $root_dir/kawauso/systems \; # clap and closer-mop
    ln -sf $root_dir/kawauso/kawauso.asd $root_dir/kawauso/systems
}

function checkout_kawauso() {
    if [ ! -e kawauso ]; then
        color_echo check out kawauso
        git clone git@github.com:garaemon/kawauso.git
    else
        color_echo updating kawauso
        (cd kawauso; git pull)
    fi
}

function install_closer_mop() {
    color_echo "installing closer-mop"
    (cd packages &&
        if [ ! -e closer-mop ]; then
            darcs get http://common-lisp.net/project/closer/repos/closer-mop/
        fi)
}

function install_clap() {
    color_echo "installing clap"
    (cd packages &&
        if [ ! -e closer-mop ]; then
            git clone git@github.com:garaemon/clap.git
        fi)
}

function install_cvs() {
    case $OS in
        Darwin)
            if [ ! -e "`which cabal`" ]; then
                install_package haskell-platform
                cabal update && cabal install darcs
            fi
            install_package git
            ;;
        Linux)
            install_package darcs
            install_package git-core
            ;;
    esac
}

function install_cl_packages() {
    color_echo installing dependent common lisp packages for bootstrap kawauso
    install_closer_mop
    install_clap
    update_asdf $root_dir/kawauso/packages
}

function boot_lisp() {
    rlwrap sbcl --eval "(progn (require :asdf) (setq asdf:*central-registry* '(#p\"${root_dir}/kawauso/systems/\")))" \
        --eval "(require :clap-builtin)"
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
install_package "sbcl"
install_package "curl"

# root directory
read -p "project root directory? [$HOME] => " root_dir
if [ "${root_dir}" == "" ]; then
    root_dir=$HOME
fi

# create directory
mkdir -p $root_dir
install_cvs

# checkout kawauso
cd $root_dir

cd kawauso
mkdir -p packages
install_cl_packages

boot_lisp
