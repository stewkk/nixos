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

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/537466eb-d108-473b-be8a-5ef2ce7da43e";
      fsType = "ext4";
    };

  fileSystems."/boot/efi" =
    { device = "/dev/disk/by-uuid/97ED-4805";
      fsType = "vfat";
    };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.grub.useOSProber = true;

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
    desktopManager.gnome = {
      enable = true;
      extraGSettingsOverrides = ''
        # Change default background
        [org.gnome.desktop.background]
        picture-uri='file://${pkgs.nixos-artwork.wallpapers.mosaic-blue.gnomeFilePath}'
        picture-uri-dark='file://${pkgs.nixos-artwork.wallpapers.mosaic-blue.gnomeFilePath}'

        [org.gnome.desktop.input-sources]
        sources=[('xkb', 'us'), ('xkb', 'ru')]

        [org.gnome.desktop.wm.keybindings]
        switch-input-source=['<Alt>Shift_L']
        switch-input-source-backward=['<Shift>Alt_L']

        [org.gnome.shell]
        favorite-apps=['emacsclient.desktop', 'org.gnome.Console.desktop', 'chromium-browser.desktop', 'telegramdesktop.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Geary.desktop', 'org.gnome.Calendar.desktop', 'org.gnome.Evince.desktop', 'com.github.johnfactotum.Foliate.desktop']
        disabled-extensions=['window-list@gnome-shell-extensions.gcampax.github.com', 'windowsNavigator@gnome-shell-extensions.gcampax.github.com', 'workspace-indicator@gnome-shell-extensions.gcampax.github.com']
        app-picker-layout=[{'emacs.desktop': <{'position': <0>}>, 'org.gnome.Photos.desktop': <{'position': <1>}>, 'org.gnome.Calculator.desktop': <{'position': <2>}>, 'simple-scan.desktop': <{'position': <3>}>, 'org.gnome.Settings.desktop': <{'position': <4>}>, 'gnome-system-monitor.desktop': <{'position': <5>}>, 'nixos-manual.desktop': <{'position': <6>}>, 'org.gnome.Cheese.desktop': <{'position': <7>}>, 'Utilities': <{'position': <8>}>}]

        [org.gnome.desktop.app-folders.folders.Utilities]
        apps=['gnome-abrt.desktop', 'gnome-system-log.desktop', 'nm-connection-editor.desktop', 'org.gnome.baobab.desktop', 'org.gnome.Connections.desktop', 'org.gnome.DejaDup.desktop', 'org.gnome.Dictionary.desktop', 'org.gnome.DiskUtility.desktop', 'org.gnome.eog.desktop', 'org.gnome.Evince.desktop', 'org.gnome.FileRoller.desktop', 'org.gnome.fonts.desktop', 'org.gnome.seahorse.Application.desktop', 'org.gnome.tweaks.desktop', 'org.gnome.Usage.desktop', 'vinagre.desktop', 'umpv.desktop', 'org.gnome.TextEditor.desktop', 'mpv.desktop', 'kitty.desktop', 'org.gnome.Tour.desktop', 'yelp.desktop', 'org.gnome.Totem.desktop', 'org.gnome.Extensions.desktop', 'org.gnome.Maps.desktop', 'org.gnome.Weather.desktop', 'org.gnome.Contacts.desktop', 'org.gnome.clocks.desktop', 'nvim.desktop', 'xterm.desktop', 'org.gnome.Epiphany.desktop', 'org.gnome.Music.desktop']

        [org.gnome.desktop.peripherals.touchpad]
        natural-scroll=false
        tap-to-click=true

        [org.gnome.shell.app-switcher]
        current-workspace-only=true

        [org.gnome.shell.window-switcher]
        current-workspace-only=true
      '';

      extraGSettingsOverridePackages = [
        pkgs.gsettings-desktop-schemas # for org.gnome.desktop
        pkgs.gnome.gnome-shell # for org.gnome.shell
      ];
    };
    displayManager.gdm.enable = true;
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
      TERMINAL = "kgx";
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
        TERMINAL = "kgx";
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
      # zathura # pdf

      man-pages
      man-pages-posix

      xournalpp
    ];

    xdg.configFile."doom/config.el".source = configs/doom/config.el;
    xdg.configFile."doom/custom.el".source = configs/doom/custom.el;
    xdg.configFile."doom/init.el".source = configs/doom/init.el;
    xdg.configFile."doom/packages.el".source = configs/doom/packages.el;
  };

  nixpkgs.config = {
    allowUnfree = true;
  };

  nixpkgs.overlays = [
    (final: prev: {
      gnome = prev.gnome.overrideScope' (gfinal: gprev: {
        mutter = prev.gnome.mutter.overrideAttrs (o: { patches = o.patches ++ [ ./configs/mutter/0001-Revert-backends-native-Disable-touch-mode-with-point.patch ]; });
      });
    })
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    unzip
    ungoogled-chromium
    hack-font
    source-code-pro
    tldr
    tdesktop
    mpv
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
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
  };
  hardware.pulseaudio.enable = false;

  programs.gnupg.agent = {
    enable = true;
  };

  security.polkit.enable = true;

  fonts.fonts = with pkgs; [
    source-code-pro
    hack-font
  ];

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
      set -g mouse on

      setw -g mode-keys vi
    '';
  };

  documentation.dev.enable = true;

  hardware.bluetooth.enable = true;
  hardware.sensor.iio.enable = true;

  hardware.opengl.extraPackages = with pkgs; [
    vaapiIntel
    libvdpau-va-gl
    vaapiVdpau
    intel-compute-runtime
    intel-media-driver
  ];

  services.peerflix.enable = true;

  services.emacs.enable = true;
  services.emacs.defaultEditor = true;

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
  networking.firewall.enable = true;

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
        fi
      '';
  };

}
