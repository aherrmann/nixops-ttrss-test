{ config, lib, pkgs, serverInfo, php, ... }:

with lib;

let

  ttrssRoot = pkgs.stdenv.mkDerivation rec {
    name = "ttrss-1.12";

    src = pkgs.fetchurl {
      url = http://github.com/gothfox/Tiny-Tiny-RSS/archive/1.12.tar.gz;
      sha256 = "1bjj66yc5wlra7zd2bkmqsh9rwnrry92qclg9gwm75l6aw653l85";
    };

    installPhase = ''
      ensureDir $out
      cp -r * $out
    '';
  };

in

{
  extraConfig = ''
    ${if config.urlPrefix != "" then
        "Alias ${config.urlPrefix} ${ttrssRoot}"
      else
        ""
    }
  '';

  documentRoot = if config.urlPrefix == "" then ttrssRoot else null;

  enablePHP = true;

  options = {
    urlPrefix = mkOption {
      default = "";
      description = ''
        The URL prefix under which the TTRSS service appears.
      '';
    };
  };
}
