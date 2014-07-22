{
  network.description = "Tiny Tiny RSS";

  webserver = 
    { config, pkgs, ... }:

    with pkgs.lib;

    {
      # Webserver
      services.httpd = {
        enable = true;
        adminAddr = "admin@example.com";
        extraSubservices = singleton
          { function = import ./ttrss-service.nix;
            siteHostName = "192.168.56.101";
          };
      };

      # Database
      services.postgresql = {
        enable = true;
        package = pkgs.postgresql;
        authentication = ''
          local ttrss all ident map=ttrssusers
          local all all ident
        '';
        identMap = ''
          ttrssusers root   ttrss
          ttrssusers wwwrun ttrss
        '';
      };

      services.ttrssUpdate = {};

      # Firewall
      networking.firewall.allowedTCPPorts = [ 80 ];
    };
}
