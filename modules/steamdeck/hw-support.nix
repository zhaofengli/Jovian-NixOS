{ config, lib, ... }:

# Misc. settings set-up by the hw-support package

let
  inherit (lib)
    mkDefault
    mkIf
    mkMerge
    mkOption
    types
  ;
  cfg = config.jovian.devices.steamdeck;
in
{
  options = {
    jovian.devices.steamdeck = {
      enableDefaultSysctlConfig = mkOption {
        default = cfg.enable;
        type = types.bool;
        description = ''
          Whether to enable stock sysctl configs.
        '';
      };
      enableDefaultCmdlineConfig = mkOption {
        default = cfg.enable;
        type = types.bool;
        description = ''
          Whether to enable stock kernel command line flags.
        '';
      };
      enableDefaultStage1Modules = mkOption {
        default = cfg.enable;
        type = types.bool;
        description = ''
          Whether to enable essential kernel modules in initrd.
        '';
      };
    };
  };

  config = mkMerge [
    (mkIf (cfg.enable) {
      # Firmware is required in stage-1 for early KMS.
      hardware.enableRedistributableFirmware = true;
    })
    (mkIf (cfg.enableDefaultStage1Modules) {
      boot.initrd.kernelModules = [
        "hid-generic"

        # Touch
        "hid-multitouch"
        "i2c-designware-core"
        "i2c-designware-platform"
        "i2c-hid-acpi"

        # Gamepad
        "usbhid"
      ];
      boot.initrd.availableKernelModules = [
        "nvme"
        "sdhci"
        "sdhci_pci"
        "cqhci"
        "mmc_block"
      ];
    })
    (mkIf (cfg.enableDefaultCmdlineConfig) {
      boot.kernelParams = [
        # From grub-steamos
        "amd_iommu=off"
        "amdgpu.gttsize=8128"
        "spi_amd.speed_dev=1"
        "audit=0"
      ];
    })
    (mkIf (cfg.enableDefaultSysctlConfig) {
      boot.kernel.sysctl = {
        # From 99-sysctl.conf
        "kernel.sched_cfs_bandwidth_slice_u" = mkDefault 3000;
        "kernel.sched_latency_ns" = mkDefault 3000000;
        "kernel.sched_min_granularity_ns" = mkDefault 300000;
        "kernel.sched_wakeup_granularity_ns" = mkDefault 500000;
        "kernel.sched_migration_cost_ns" = mkDefault 50000;
        "kernel.sched_nr_migrate" = mkDefault 128;
      };
    })
  ];
}
