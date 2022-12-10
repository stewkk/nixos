# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      <home-manager/nixos>
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  networking.hostName = "nixos"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Moscow";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_DK.UTF-8";
    LC_IDENTIFICATION = "en_DK.UTF-8";
    LC_MEASUREMENT = "en_DK.UTF-8";
    LC_MONETARY = "en_DK.UTF-8";
    LC_NAME = "en_DK.UTF-8";
    LC_NUMERIC = "en_DK.UTF-8";
    LC_PAPER = "en_DK.UTF-8";
    LC_TELEPHONE = "en_DK.UTF-8";
    LC_TIME = "en_DK.UTF-8";
  };

  # Configure keymap in X11
  services.xserver = {
    enable = true;
    layout = "us,ru";
    xkbOptions = "grp:alt_shift_toggle";
    windowManager.qtile.enable = true;
    libinput.enable = true;
    libinput.touchpad = {
      tapping = true;
    };
    videoDrivers = [ "intel" ];
    xautolock = {
      enable = true;
      time = 5;
      locker = "${pkgs.lightlocker}/bin/light-locker-command -l";
    };
  };

  programs.ssh.startAgent = true;
  programs.ssh.extraConfig = "AddKeysToAgent yes";

  programs.neovim.enable = true;
  programs.neovim.vimAlias = true;
  programs.neovim.viAlias = true;

  virtualisation.docker.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.st = {
    isNormalUser = true;
    description = "Alexandr Starovoytov";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [];
  };

  home-manager.users.st = { pkgs, ... }: {
    home.username = "st";
    home.homeDirectory = "/home/st";

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    home.stateVersion = "22.11";

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;

    home.sessionVariables = {
      EDITOR = "nvim";
      BROWSER = "chromium";
      TERMINAL = "kitty";
    };

    programs.bash = {
      enable = true;
      bashrcExtra = ''
        set -o vi
        eval "$(direnv hook bash)"
      '';
      sessionVariables = {
        EDITOR = "nvim";
        BROWSER = "chromium";
        TERMINAL = "kitty";
      };
      initExtra = ''
          . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
        '';
    };

    home.packages = with pkgs; [
      dconf

      emacs    # Emacs 27.2
      ripgrep
      coreutils # basic GNU utilities
      fd
      clang

      foliate # epub
      zathura # pdf

      man-pages
      man-pages-posix
    ];

    programs.kitty = {
      enable = true;
      font = {
        package = pkgs.hack-font;
        name = "monospace";
      };
      theme = "Tokyo Night";
      settings = {
        font_size = 14;
        cursor_blink_interval = 0;
        scrollback_pager_history_size = 4;
        enable_audio_bell = "no";
        update_check_interval = 0;
        confirm_os_window_close  = 0;
        scrollback_pager = ''nvim  -c "set nonumber nolist showtabline=0 foldcolumn=0" -c "autocmd TermOpen * normal G" -c "silent write! /tmp/kitty_scrollback_buffer | te cat /tmp/kitty_scrollback_buffer - "'';
      };
    };

    xdg.configFile."qtile/config.py".source = configs/qtile.py;
    xdg.configFile."qtile/autostart.sh".source = configs/autostart.sh;

    xdg.configFile."doom/config.el".source = configs/doom/config.el;
    xdg.configFile."doom/custom.el".source = configs/doom/custom.el;
    xdg.configFile."doom/init.el".source = configs/doom/init.el;
    xdg.configFile."doom/packages.el".source = configs/doom/packages.el;

    gtk = {
      enable = true;
      theme = {
        package = pkgs.gnome.gnome-themes-extra;
        name = "Adwaita-dark";
      };
    };
  };

  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = pkgs: rec {
      dmenu = pkgs.dmenu.override {
        patches = [ ./configs/dmenu/tokyo-night.diff ];
      };
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    unzip
    ungoogled-chromium
    hack-font
    source-code-pro
    nitrogen
    polkit_gnome
    brightnessctl
    dmenu
    maim
    tldr
    xdotool
    xclip
    pavucontrol
    tdesktop
    pyright
    mpv
    lightlocker
    pinentry-gtk2
    gnumake
    clang-tools
    direnv
  ];

  programs.git = {
    enable = true;
    config = {
      user = {
        email = "aistarovoytov@yandex.ru";
        name = "Alexandr Starovoytov";
      };
      commit.gpgsign = true;
    };
  };
  services.pcscd.enable = true;

  services.lorri.enable = true;

  programs.gnupg.agent = {
    enable = true;
    pinentryFlavor = "gtk2";
  };

  security.polkit.enable = true;

  fonts.fonts = with pkgs; [
    source-code-pro
    hack-font
  ];

  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wants = [ "graphical-session.target" ];
      wantedBy = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };

  programs.dconf.enable = true; # for gtk config

  programs.tmux = {
    enable = true;
    shortcut = "a";
    baseIndex = 1;
    newSession = true;
    # Stop tmux+escape craziness.
    escapeTime = 0;

    extraConfig = ''
      # https://old.reddit.com/r/tmux/comments/mesrci/tmux_2_doesnt_seem_to_use_256_colors/
      set -g default-terminal "xterm-256color"
      set -ga terminal-overrides ",*256col*:Tc"
      set -ga terminal-overrides '*:Ss=\E[%p1%d q:Se=\E[ q'
      set-environment -g COLORTERM "truecolor"

      setw -g mode-keys vi
    '';
  };

  documentation.dev.enable = true;

  services.blueman.enable = true;
  hardware.bluetooth.enable = true;

  hardware.opengl.extraPackages = with pkgs; [
    vaapiIntel
    libvdpau-va-gl
    vaapiVdpau
    intel-compute-runtime
    intel-media-driver
  ];

  services.picom = {
    enable = true;
    fade = true;
    shadow = true;
    fadeDelta = 4;
  };

  services.pipewire = {
    enable = true;
    wireplumber.enable = true;
    pulse.enable = true;
    audio.enable = true;
  };

  services.emacs.enable = true;
  services.emacs.defaultEditor = true;

  programs.nm-applet.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

  system.userActivationScripts = {
    installDoomEmacs = ''
        if [ ! -d ~/.emacs.d ]; then
           "${pkgs.git}"/bin/git clone --depth=1 --single-branch "https://github.com/doomemacs/doomemacs.git" ~/.emacs.d
           # git clone configRepoUrl "$XDG_CONFIG_HOME/doom"
        fi
      '';
  };

}
