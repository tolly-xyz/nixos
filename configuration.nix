# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      inputs.home-manager.nixosModules.default
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # nvidia things
  # thanks Vimjoyer https://www.youtube.com/watch?v=qlfm3MEbqYA
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.nvidia = {
    prime = {
      # nix shell nixpkgs#pciutils -c lspci | grep ' VGA '
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";

      # use `nvidia-offload` to use GPU for command
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
    };
    modesetting.enable = true;
    open = false;
  };

  specialisation = {
    gpu-sync.configuration = {
      hardware.nvidia = {
        prime.sync.enable = lib.mkForce true;
        prime.offload = {
          enable = lib.mkForce false;
          enableOffloadCmd = lib.mkForce false;
        };
      };
    };
  };

  services.xserver = {
    # Enable the X11 windowing system.
    enable = true;

    # Enable the GNOME Desktop Environment.
    displayManager.gdm.enable = true;
    desktopManager = {
      gnome.enable = true;
      wallpaper.mode = "center";
    };

    videoDrivers = [ "nvidia" ];

    # Configure keymap in X11
    xkb.layout = "us";
    # services.xserver.xkb.options = "eurosign:e,caps:escape";
  };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # jack.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.tolly = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      android-tools
      cargo-tauri
      fastfetch
      ffmpeg
      firefox
      gh
      google-chrome
      obs-studio
      prismlauncher # minecraft
      yt-dlp
    ];
  };

  home-manager = {
    extraSpecialArgs = {
      inherit inputs;
    };
    users = {
      tolly = import ./home.nix;
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs;
    [
      alacritty
      btop
      bun
      discord
      fzf
      gcc
      dconf-editor
      flameshot
      ghc
      ghostscript
      gnumake
      gnutar
      htop
      krita
      libnotify
      lmstudio
      mangohud
      neovim
      nerdfonts
      nodejs_22
      protonup
      protonvpn-gui
      python3
      ripgrep
      rustup
      tmux
      unzip
      vim
      wezterm
      wget
      yarn
      zig
      zip
    ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  programs.dconf = {
    enable = true;
    # profiles = {
    #   user = {
    #     databases = [
    #       {
    #         keyfiles = [ /home/tolly/.config/dconf/user.d ];
    #       }
    #     ];
    #   };
    # };
  };

  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    config = {
      credential.helper = "libsecret";
      diff.tool = "nvimdiff";
      difftool.prompt = false;
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      user = {
        name = "tolly";
        email = "40471358+orrefailaT@users.noreply.github.com";
      };
    };
    prompt.enable = true;
  };

  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
  };

  programs.gamemode.enable = true;

  programs.nix-ld.enable = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  nix.settings.auto-optimise-store = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?

}

