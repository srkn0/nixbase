# Partition layout for xps17's second disk (first disk keeps Windows + its
# ESP untouched). Single LUKS container wrapping an LVM VG so root+swap
# share one unlock (TPM2-bound, see default.nix) instead of two volumes.
{
  disko.devices = {
    disk.xps17-nixos = {
      device = "/dev/disk/by-id/nvme-PC_SN730_NVMe_WDC_512GB_194591806841";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size     = "512M";
            type     = "EF00";
            priority = 1;
            content = {
              type        = "filesystem";
              format      = "vfat";
              mountpoint  = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };
          luks = {
            size     = "100%";
            priority = 2;
            content = {
              type = "luks";
              name = "cryptroot";
              settings.allowDiscards = true;
              content = {
                type = "lvm_pv";
                vg   = "pool";
              };
            };
          };
        };
      };
    };

    lvm_vg.pool = {
      type = "lvm_vg";
      lvs = {
        # Fixed sizes on both LVs, not `100%FREE` — its resolution order
        # across an unordered Nix attrset isn't guaranteed. ~8G of the VG
        # is left as slack; `lvextend -l+100%FREE` + `resize2fs` to reclaim.
        swap = {
          size = "48G"; # ~1.5x the laptop's 32G RAM, sized for hibernation
          content = {
            type          = "swap";
            resumeDevice  = true;
            discardPolicy = "both";
          };
        };
        root = {
          size = "420G";
          content = {
            type       = "filesystem";
            format     = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };
}
