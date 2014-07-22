# Tiny Tiny RSS -- NixOps Module

[TTRSS][ttrss] is a RSS/Atom feed aggregator and reader.

This NixOps module contains a configuration to deploy an Apache webserver, that
runs TTRSS.

**TODO**:

 * Register the [feed-update daemon][update] as a NixOS service.

## How to deploy.

Execute the following commands in order to create, and deploy a VirtualBox
machine.

    nixops create ./ttrss.nix ./ttrss-vbox.nix -d ttrss
    nixops deploy -d ttrss

Enter the IP address of the virtual machine into your browser address bar to
view the TTRSS page.


[ttrss]: http://tt-rss.org/redmine/projects/tt-rss/wiki
[update]: http://tt-rss.org/redmine/projects/tt-rss/wiki/UpdatingFeeds
