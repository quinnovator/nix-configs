# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.initrd.kernelModules = [ "nvidia" ];

  boot.kernelParams = [
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    "nvidia.NVreg_TemporaryFilePath=/tmp"
  ];

  boot.initrd.luks.devices."luks-5eb47789-06a9-4d04-aa76-9b36b7e4bd33".device =
    "/dev/disk/by-uuid/5eb47789-06a9-4d04-aa76-9b36b7e4bd33";
  networking.hostName = "jack_nix"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant (not used with network manager)

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Nix cleanup
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than +3";
  };

  nix.optimise.automatic = true;

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.jack = {
    isNormalUser = true;
    description = "Jack Quinn";
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
    ];

    shell = pkgs.fish;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGpX3uqlCkwMZ1o89kVZNApwhmPop9R71yheoZFimRHc jack_nix"
    ];
  };

  # Enable automatic Hyprland session on reboot
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.hyprland}/bin/Hyprland";
        user = "jack";
      };
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # GPU/Graphics
  hardware.graphics = {
    enable = true;
    enable32Bit = true;

    extraPackages = with pkgs; [
      nvidia-vaapi-driver
    ];
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  services.colord.enable = true;

  hardware.nvidia = {
    # 5080M requires open source kernel modules
    open = true;

    # Wayland/PRIME requires modesetting
    modesetting.enable = true;

    nvidiaSettings = true;

    nvidiaPersistenced = true;

    powerManagement = {
      enable = true;
      finegrained = true;
    };

    package = config.boot.kernelPackages.nvidiaPackages.latest;

    prime = {
      reverseSync.enable = true;

      nvidiaBusId = "PCI:197:0:0";
      amdgpuBusId = "PCI:198:0:0";
    };
  };

  environment.variables = {
    AQ_DRM_DEVICES = "/dev/dri/card2:/dev/dri/card1";

    NVD_BACKEND = "direct";

    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    LIBVA_DRIVER_NAME = "nvidia";

    NIXOS_OZONE_WL = "1";

    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "Hyprland";
  };

  programs.fish.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    pkgs.kitty
    pkgs.dunst

    pkgs.hyprpolkitagent
    pkgs.hyprpaper
    pkgs.hyprsunset

    # General
    vim
    wget
    pciutils

    # GPU Utils
    nvtopPackages.nvidia

    vulkan-tools
    vulkan-loader

    egl-wayland
    wayland-protocols
  ];

  # Hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;

    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };

    openFirewall = true;
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

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
  system.stateVersion = "25.05"; # Did you read the comment?

}
