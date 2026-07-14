# Partition layout for x230 (single internal disk). Single LUKS container
# wrapping an LVM VG so root+swap share one unlock, passphrase-only.
{
  disko.devices = {
    disk.x230-nixos = {
      device = "/dev/disk/by-id/TODO";
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
          size = "8G"; # placeholder — resize to ~1.5x actual RAM once known
          content = {
            type          = "swap";
            resumeDevice  = true;
            discardPolicy = "both";
          };
        };
        root = {
          size = "100%"; # placeholder — pin to a fixed size once disk is known,
                          # not 100%FREE (LV allocation order isn't guaranteed)
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
