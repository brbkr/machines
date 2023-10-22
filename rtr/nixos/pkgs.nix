{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    bc
    # bintools-unwrapped avoids wrapper scripts
    # https://nixos.wiki/wiki/C#The_compiler_wrapper
    #bintools-unwrapped
    btop
    dmidecode
    ethtool
    file
    fwupd
    gcc
    git
    gnumake
    gptfdisk
    htop
    iftop
    iotop
    iperf3
    jq
    killall
    lm_sensors
    lshw
    lsof
    mkpasswd
    mtr
    ndisc6
    neofetch
    neovim
    nixfmt
    # Package ‘nix-linter-0.2.0.4’ in
    # /nix/store/gc404hgkcjg4ydac698c4rjz2kmwmvfl-nixos-23.05/nixos/pkgs/development/tools/analysis/nix-linter/default.nix:23
    # is marked as broken, refusing to evaluate.
    #nix-linter
    nmap
    nmon
    pciutils
    pkg-config
    pv
    ripgrep
    smartmontools
    sysstat
    tailscale
    tcpdump
    tmux
    tree
    unixtools.xxd
    unzip
    usbutils
    wget
  ];
}
