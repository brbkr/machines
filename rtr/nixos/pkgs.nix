{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    bc
    # bintools-unwrapped avoids wrapper scripts
    # https://nixos.wiki/wiki/C#The_compiler_wrapper
    bintools-unwrapped
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
    lsscsi
    mkpasswd
    mtr
    ndisc6
    neofetch
    nixfmt
    # Broken as of June 1, 2023.
    # nix-linter
    nmap
    nmon
    pciutils
    pkg-config
    pv
    ripgrep
    smartmontools
    sysstat
    tcpdump
    tmux
    tree
    unixtools.xxd
    unzip
    usbutils
    wget
  ];
}
