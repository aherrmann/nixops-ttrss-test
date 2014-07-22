{ config, lib, pkgs, ... }:

with lib;

{

  ###### interface

  options = {

    services.ttrssUpdate = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to run the TTRSS update daemon.";
      };

    };

  };


  ###### implementation

  config = mkIf config.services.ttrssUpdate.enable {

    systemd.services.ttrssUpdate =
      let
        php = pkgs.php;
        ttrssRoot = pkgs.ttrss;
      in
      {
        description = "Updates TTRSS feeds.";

        wantedBy = [ "multi-user.target" ];

        after = [ "postgresql.service" "httpd.service" ];

        serviceConfig.ExecStart = ''
          ${php}/bin/php ${ttrssRoot}/update.php --daemon
        '';
      };

  };

}
