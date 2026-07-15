# Partition layout for x230 (single internal disk). Single LUKS container
# wrapping an LVM VG so root+swap share one unlock, passphrase-only.
{
  disko.devices = {
    disk.x230-nixos = {
      device = "/dev/disk/by-id/ata-Samsung_SSD_850_EVO_1TB_S2RFNXAH308074E";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size     = "512MiB";
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
        swap = {
          size = "24G"; # 16G RAM × 1.5
          content = {
            type          = "swap";
            resumeDevice  = true;
            discardPolicy = "both";
          };
        };
        root = {
          size = "100%FREE";
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
