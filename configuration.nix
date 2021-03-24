# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
#let
  #nixos-unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
  #nixpkgs-19-03 = import (fetchTarball https://releases.nixos.org/nixos/19.03/nixos-19.03.173684.c8db7a8a16e/nixexprs.tar.xz) { };
#in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./cachix.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "Shiva"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n = {
  #   consoleFont = "Lat2-Terminus16";
  #   consoleKeyMap = "us";
  #   defaultLocale = "en_US.UTF-8";
  # };

  # Set your time zone.
  time.timeZone = "America/Mexico_City";

  # environment.variables = {
  #   TERMINAL = [ "st" ];
  #   OH_MY_ZSH = [ "${pkgs.oh-my-zsh}/share/oh-my-zsh" ];
  # };
  
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  nixpkgs.config.allowUnfree = true;

  environment.interactiveShellInit = ''
    # alias fn='cabal repl' #TODO:Fix
    # alias 'cabal run'='cabal new-run' #TODO:Fix
    # alias 'cabal build'='cabal new-build' #TODO:Fix
    alias cat='bat'
    alias _cat='cat'
    alias crun='cabal new-run'
    alias ct='cabal new-test'
    alias cr='cabal new-repl'
    alias cb='cabal new-build'
    alias sr='cd ~/src/stand-in-language && cabal new-run sil-mini-repl -- --haskell'
    alias sil-repl='cd ~/src/stand-in-language && cabal new-run sil-mini-repl -- --haskell'
    alias gs='git status'
    alias ga='git add -A'
    alias gd='git diff'
    alias gc='git commit -am'
    alias gcs='git commit -am "squash"'
    alias sendmail='/run/current-system/sw/bin/msmtp --debug --from=default --file=/etc/msmtp/laurus -t'
    alias xclip='xclip -selection c'
    alias please='sudo'
    alias n='nix-shell shell.nix'
    alias nod='nixops deploy -d laurus-nobilis-gce'
    alias sn='sudo nixos-rebuild switch'
    alias gr='grep -R --exclude='TAGS' --exclude-dir={.stack-work,dist-newstyle,result,result-2} -n'
    alias where='pwd'
    alias sendmail='/run/current-system/sw/bin/msmtp --debug --from=default --file=/etc/msmtp/laurus -t'
  '';

  environment.systemPackages = with pkgs; [
    stylish-haskell
    ghc
    bat 
    unetbootin
    any-nix-shell
    texlive.combined.scheme-basic
    rxvt_unicode
    wget
    vim
    emacs
    tmux
    curl
    gist
    git
    lambda-mod-zsh-theme
    oh-my-zsh
    zsh
    scrot
    xclip
    feh
    firefox
    dmenu
    tabbed
    st
    haskellPackages.xmobar
    ranger
    # fish
    obs-studio
    qbittorrent
    libreoffice
    vlc
    dropbox-cli
    gnome3.nautilus
    calibre
    # taffybar
    sshpass
    gimp
    gparted
    octave
    htop
    stack
    postgresql_11
    nixops
    # skypeforlinux
    google-chrome
    # spotify # this loops `nixos-rebuild switch` 
    # stack2nix
    #nixos-unstable.ghc
    ffmpeg
    xdotool
    cabal2nix
    cabal-install
    nix-prefetch-git
    xvkbd
    haskellPackages.yesod-bin
    # system-sendmail
    msmtp
    hunspell
    hunspellDicts.es-any
    hunspellDicts.es-mx
    hunspellDicts.en-us
    aspell
    aspellDicts.en
    aspellDicts.en-computers
    aspellDicts.en-science
    aspellDicts.es
    inkscape

    # haskellPackages.keter
    # nixos.zathura
    unrar
    unzip
    teamviewer
    hack-font
    cachix
    tree
    gnumake
    nodejs
    nodePackages.yarn
    #nixpkgs-19-03.yarn2nix
    nodePackages.typescript
    nodePackages.create-react-app
  ];

  #security.pki.certificateFiles = [ /home/joshuabc/.ssh/id_rsa ];


  # TODO: see about this.
  nixpkgs.config.permittedInsecurePackages = [
    "google-chrome-81.0.4044.138"
  ];

  fonts.fonts = with pkgs; [
    hack-font
  ];

  systemd.user.services.dropbox = {
    restartIfChanged = true;
    enable = true;
    serviceConfig = {
      ExecStart = "${pkgs.dropbox}/bin/dropbox";
      PassEnvironment = "DISPLAY";
    };
  };
  systemd.user.services."urxvtd" = {
    enable = true;
    description = "rxvt unicode daemon";
    wantedBy = [ "default.target" ];
    path = [ pkgs.rxvt_unicode ];
    serviceConfig.Restart = "always";
    serviceConfig.RestartSec = 2;
    serviceConfig.ExecStart = "${pkgs.rxvt_unicode}/bin/urxvtd -q -o";
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    interactiveShellInit = ''
      # z - jump around
      # source ${pkgs.fetchurl {url = "https://github.com/rupa/z/raw/2ebe419ae18316c5597dd5fb84b5d8595ff1dde9/z.sh"; sha256 = "0ywpgk3ksjq7g30bqbhl9znz3jh6jfg8lxnbdbaiipzgsy41vi10";}}
      save_aliases=$(alias -L)
      export ZSH=${pkgs.oh-my-zsh}/share/oh-my-zsh
      export ZSH_THEME="bira" #"lambda"
      plugins=(git sudo colorize extract history postgres)
      source $ZSH/oh-my-zsh.sh
      eval $save_aliases; unset save_aliases
    '';
    promptInit = ''
      any-nix-shell zsh --info-right | source /dev/stdin
  '';
  };
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };
  # programs.fish.enable = true;
  # programs.fish.promptInit = ''
  #   fish-nix-shell --info-right | source
  # '';
  # programs.zsh.interactiveShellInit = ''
  #   export ZSH=${pkgs.oh-my-zsh}/share/oh-my-zsh/

  #   # Customize your oh-my-zsh options here
  #   ZSH_THEME="bira"
  #   plugins=(git dnf sudo colorize extract history postgres)

  #   source $ZSH/oh-my-zsh.sh
  # '';
  # programs.zsh.promptInit = ""; # Clear this to avoid a conflict with oh-my-zsh
  
  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 3000 5432 587 5938 ];
  networking.firewall.allowedUDPPorts = [ 5938 ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system.
  # services.xserver.enable = true;
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";
  services.openssh.enable = true;

  services.sshd.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "ctrl:nocaps";
  services.xserver.xkbVariant = "altgr-intl";
  services.xserver.windowManager.xmonad = {
    enable = true;
    enableContribAndExtras = true;
    extraPackages = haskellPackages:[
      haskellPackages.xmonad-contrib
      haskellPackages.xmonad-extras
      haskellPackages.xmonad
    ];
  };
  services.xserver.displayManager = {
    defaultSession = "gnome";
    gdm.enable = true;
    gdm.autoLogin.user = "joshuabc";
  };
  services.xserver.desktopManager.gnome3.enable = true;

  services.postgresql = {
      enable = true;
      package = pkgs.postgresql_11;
      enableTCPIP = true;
      authentication = pkgs.lib.mkOverride 10 ''
        local all all trust
        host all all ::1/128 trust
      '';
      initialScript = pkgs.writeText "backend-initScript" ''
        CREATE ROLE analyzer WITH LOGIN PASSWORD 'anapass' CREATEDB;
        CREATE DATABASE aanalyzer_yesod;
        GRANT ALL PRIVILEGES ON DATABASE analyzer TO aanalyzer_yesod;

        CREATE ROLE hhefesto WITH LOGIN PASSWORD 'hhefesto' CREATEDB;
        CREATE DATABASE sandbox;
        GRANT ALL PRIVILEGES ON DATABASE sandbox TO hhefesto;
    '';
  };

  virtualisation.docker.enable = true;
  virtualisation.virtualbox.host.enable = true;
  
  # Enable touchpad support.
  # services.xserver.libinput.enable = true;

  # Enable the KDE Desktop Environment.
  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.desktopManager.plasma5.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.jane = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  # };
  

  users.mutableUsers = false;

  # Password generated with ```mkpasswd -m sha-512```
  # users.users.root.initialHashedPassword = "$6$n4g4i9VHr52IqYY$7DMpovz3Z91gSpnfrGPPw.s1DfbdpyfJnwjv7on4G1gtFCOr0PaWOcJUHREuGzZwKZORnx7SOFAqgyehW.nxz/";
  users.users.root.initialHashedPassword = "$6$go2j49b0tA$99LAebgNhiD3CDrEY5CDvGQQqFzFLtxx2SySykrQc/SOijSFllGUMN2lqHVGLXweraFI/aUbSLsd6R7NMoJTA/";
  users.users.joshuabc.initialHashedPassword = "$6$go2j49b0tA$99LAebgNhiD3CDrEY5CDvGQQqFzFLtxx2SySykrQc/SOijSFllGUMN2lqHVGLXweraFI/aUbSLsd6R7NMoJTA/";

  # users.users.hhefesto.initialHashedPassword = "$6$n4g4i9VHr52IqYY$7DMpovz3Z91gSpnfrGPPw.s1DfbdpyfJnwjv7on4G1gtFCOr0PaWOcJUHREuGzZwKZORnx7SOFAqgyehW.nxz/"; # this may be redundant
  # users.defaultUserShell = pkgs.zsh;

  users.extraUsers.joshuabc = {
    createHome = true;
    isNormalUser = true;
    home = "/home/joshuabc";
    description = "Joshua Barceinas Cabrera";
    extraGroups = [ "wheel" "networkmanager" "docker" ];
    hashedPassword = "$6$go2j49b0tA$99LAebgNhiD3CDrEY5CDvGQQqFzFLtxx2SySykrQc/SOijSFllGUMN2lqHVGLXweraFI/aUbSLsd6R7NMoJTA/";
    shell = pkgs.zsh;
  };

  users.extraUsers.enriquead = {
    createHome = true;
    isNormalUser = true;
    home = "/home/enriquead";
    description = "Luis Enrique Aguilar Diaz";
    extraGroups = [ "wheel" "networkmanager" "docker" ];
    hashedPassword = "$6$IL1uvKLIkU/$YQdjkGdHBJE0DdPJYruwUNf2hYGp9Gy4WBWjTYXSyAstm.i0VLHFaZTKN.stChEqQhMjDJtIiBSaIu/Etu76I1";
    shell = pkgs.zsh;
  };
  
  users.extraUsers.vichebar = {
    createHome = true;
    isNormalUser = true;
    home = "/home/vichebar";
    description = "Victor Alexis Hernandez Barron";
    extraGroups = [ "wheel" "networkmanager" "docker" ];
    hashedPassword = "$6$YPAXtD7Nvl4$LT41BH63iNvteUUH3LSrsoSFn2eFjWyYAb/eJRRNV4layOy3CCwO0m9iQvZu2DR2zUxKMoY4op65NxUYE4VqB1";
    shell = pkgs.zsh; #"/run/current-system/sw/bin/bash";
  };

  users.extraUsers.hhefesto = {
    createHome = true;
    isNormalUser = true;
    home = "/home/hhefesto";
    description = "Daniel";
    extraGroups = [ "wheel" "networkmanager" "docker" ];
    hashedPassword = "$6$n4g4i9VHr52IqYY$7DMpovz3Z91gSpnfrGPPw.s1DfbdpyfJnwjv7on4G1gtFCOr0PaWOcJUHREuGzZwKZORnx7SOFAqgyehW.nxz/";
    shell = pkgs.zsh; #"/run/current-system/sw/bin/bash";
  };

  # texlive.combine {
  #   inherit (texlive) scheme-small algorithms cm-super;
  # };

  #added for obelisk https://github.com/obsidiansystems/obelisk
  nix.binaryCaches = [ "https://nixcache.reflex-frp.org" ];
  nix.binaryCachePublicKeys = [ "ryantrinkle.com-1:JJiAKaRv9mWgpVAz8dwewnZe0AzzEAzPkagE9SP5NWI=" ];

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.

  system.stateVersion = "19.03"; # Did you read the comment? Yes 20.09 or 19.03 last
  nix.allowedUsers =  [ "@wheel" "enriquead" ];
  nix.trustedUsers = [ "root" "enriquead" ];

  #Nos deshacemos de nix-channel
  nix.package = pkgs.nixFlakes;
  nix.extraOptions = "experimental-features = nix-command flakes";
}
