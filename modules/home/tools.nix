{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [ mise ];

  home.file.".config/mise/config.toml".source = ../../mise/config.toml;

  # Best-effort `mise install` on every home-manager switch (i.e. every rebuild)
  # and after the initial bootstrap. Guarded on network + `|| true` so it can
  # never fail the switch when offline. mise runtimes live outside Nix, so this
  # keeps them materialised without a manual step.
  home.activation.miseInstall = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export PATH="${lib.makeBinPath [ pkgs.mise pkgs.git pkgs.curl pkgs.gnutar pkgs.gzip pkgs.unzip pkgs.coreutils ]}:$PATH"
    if timeout 4 ${pkgs.curl}/bin/curl -sfI https://github.com >/dev/null 2>&1; then
      echo "mise: installing runtimes…" >&2
      ${pkgs.mise}/bin/mise install --yes || true
    else
      echo "mise: offline — skipping 'mise install'" >&2
    fi
  '';
}
