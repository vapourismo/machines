{
  pkgs,
  specialArgs,
  ...
}: let
  src = specialArgs.inputs.tezos;

  shell = import (src + /shell.nix);

  deps = pkgs.lib.lists.concatLists [
    shell.buildInputs
    shell.nativeBuildInputs
    shell.propagatedBuildInputs
    shell.propagatedNativeBuildInputs
  ];

  package = pkgs.stdenv.mkDerivation {
    pname = "tezos";
    version = src.rev;

    inherit src;
    inherit (shell) NIX_LDFLAGS NIX_CFLAGS_COMPILE TEZOS_WITHOUT_OPAM OPAM_SWITCH_PREFIX;

    buildInputs = deps ++ [pkgs.makeWrapper];

    dontConfigure = true;

    buildPhase = ''
      make PROFILE=release octez-node octez-client
    '';

    installPhase = ''
      mkdir -p $out/bin $out/share
      cp octez-node octez-client $out/bin
    '';

    postFixup = ''
      wrapProgram $out/bin/octez-node --set OPAM_SWITCH_PREFIX ${shell.OPAM_SWITCH_PREFIX}
      wrapProgram $out/bin/octez-client --set OPAM_SWITCH_PREFIX ${shell.OPAM_SWITCH_PREFIX}
    '';
  };
in {
  systemd.services = {
    tezos-node = {
      enable = true;
      wantedBy = ["multi-user.target"];
      script = ''
        ${package}/bin/octez-node run --rpc-addr 127.0.0.1:8732
      '';
    };
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts."tezos.hwlium.com" = {
      enableACME = true;
      forceSSL = true;

      locations."/" = {
        proxyPass = "http://127.0.0.1:8732/";
        extraConfig = ''
          proxy_ssl_server_name on;
        '';
      };
    };
  };
}
