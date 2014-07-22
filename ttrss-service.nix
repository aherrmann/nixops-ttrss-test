{ config, lib, pkgs, serverInfo, php, ... }:

with lib;

let

  translateDBType = dbType:
    if dbType == "postgres" then
      "pgsql"
    else
      throw "Unknown value for `dbType`!"
      ""
    ;

  ttrssConfig = pkgs.writeText "config.php" ''
    <?php
        // *******************************************
        // *** Database configuration (important!) ***
        // *******************************************

        define('DB_TYPE', '${translateDBType config.dbType}');
        define('DB_HOST', '${config.dbServer}');
        define('DB_USER', '${config.dbUser}');
        define('DB_NAME', '${config.dbName}');
        define('DB_PASS', '${config.dbPassword}');
        define('DB_PORT', '${config.dbPort}');

        define('MYSQL_CHARSET', 'UTF8');
        // Connection charset for MySQL. If you have a legacy database and/or experience
        // garbage unicode characters with this option, try setting it to a blank string.

        // ***********************************
        // *** Basic settings (important!) ***
        // ***********************************

        define('SELF_URL_PATH', '${config.siteURL}');
        // Full URL of your tt-rss installation. This should be set to the
        // location of tt-rss directory, e.g. http://example.org/tt-rss/
        // You need to set this option correctly otherwise several features
        // including PUSH, bookmarklets and browser integration will not work properly.

        define('FEED_CRYPT_KEY', '${config.cryptKey}');
        // Key used for encryption of passwords for password-protected feeds
        // in the database. A string of 24 random characters. If left blank, encryption
        // is not used. Requires mcrypt functions.
        // Warning: changing this key will make your stored feed passwords impossible
        // to decrypt.

        define('SINGLE_USER_MODE', false);
        // Operate in single user mode, disables all functionality related to
        // multiple users and authentication. Enabling this assumes you have
        // your tt-rss directory protected by other means (e.g. http auth).

        define('SIMPLE_UPDATE_MODE', false);
        // Enables fallback update mode where tt-rss tries to update feeds in
        // background while tt-rss is open in your browser.
        // If you don't have a lot of feeds and don't want to or can't run
        // background processes while not running tt-rss, this method is generally
        // viable to keep your feeds up to date.
        // Still, there are more robust (and recommended) updating methods
        // available, you can read about them here: http://tt-rss.org/wiki/UpdatingFeeds

        // *****************************
        // *** Files and directories ***
        // *****************************

        define('PHP_EXECUTABLE', '${php}/bin/php');
        // Path to PHP *COMMAND LINE* executable, used for various command-line tt-rss
        // programs and update daemon. Do not try to use CGI binary here, it won't work.
        // If you see HTTP headers being displayed while running tt-rss scripts,
        // then most probably you are using the CGI binary. If you are unsure what to
        // put in here, ask your hosting provider.

        define('LOCK_DIRECTORY', '${config.stateDir}/lock');
        // Directory for lockfiles, must be writable to the user you run
        // daemon process or cronjobs under.

        define('CACHE_DIR', '${config.stateDir}/cache');
        // Local cache directory for RSS feed content.

        define('ICONS_DIR', "${config.stateDir}/feed-icons");
        define('ICONS_URL', "feed-icons");
        // Local and URL path to the directory, where feed favicons are stored.
        // Unless you really know what you're doing, please keep those relative
        // to tt-rss main directory.

        // **********************
        // *** Authentication ***
        // **********************

        // Please see PLUGINS below to configure various authentication modules.

        define('AUTH_AUTO_CREATE', true);
        // Allow authentication modules to auto-create users in tt-rss internal
        // database when authenticated successfully.

        define('AUTH_AUTO_LOGIN', true);
        // Automatically login user on remote or other kind of externally supplied
        // authentication, otherwise redirect to login form as normal.
        // If set to true, users won't be able to set application language
        // and settings profile.

        // *********************
        // *** Feed settings ***
        // *********************

        define('FORCE_ARTICLE_PURGE', 0);
        // When this option is not 0, users ability to control feed purging
        // intervals is disabled and all articles (which are not starred)
        // older than this amount of days are purged.

        // *** PubSubHubbub settings ***

        define('PUBSUBHUBBUB_HUB', ''');
        // URL to a PubSubHubbub-compatible hub server. If defined, "Published
        // articles" generated feed would automatically become PUSH-enabled.

        define('PUBSUBHUBBUB_ENABLED', false);
        // Enable client PubSubHubbub support in tt-rss. When disabled, tt-rss
        // won't try to subscribe to PUSH feed updates.

        // *********************
        // *** Sphinx search ***
        // *********************

        define('SPHINX_ENABLED', false);
        // Enable fulltext search using Sphinx (http://www.sphinxsearch.com)
        // Please see http://tt-rss.org/wiki/SphinxSearch for more information.

        define('SPHINX_SERVER', 'localhost:9312');
        // Hostname:port combination for the Sphinx server.

        define('SPHINX_INDEX', 'ttrss, delta');
        // Index name in Sphinx configuration. You can specify multiple indexes
        // as a comma-separated string.
        // Example configuration files are available on tt-rss wiki.

        // ***********************************
        // *** Self-registrations by users ***
        // ***********************************

        define('ENABLE_REGISTRATION', false);
        // Allow users to register themselves. Please be aware that allowing
        // random people to access your tt-rss installation is a security risk
        // and potentially might lead to data loss or server exploit. Disabled
        // by default.

        define('REG_NOTIFY_ADDRESS', '${config.notifyContact}');
        // Email address to send new user notifications to.

        define('REG_MAX_USERS', 10);
        // Maximum amount of users which will be allowed to register on this
        // system. 0 - no limit.

        // **********************************
        // *** Cookies and login sessions ***
        // **********************************

        define('SESSION_COOKIE_LIFETIME', 86400);
        // Default lifetime of a session (e.g. login) cookie. In seconds,
        // 0 means cookie will be deleted when browser closes.

        define('SESSION_CHECK_ADDRESS', 1);
        // Check client IP address when validating session:
        // 0 - disable checking
        // 1 - check first 3 octets of an address (recommended)
        // 2 - check first 2 octets of an address
        // 3 - check entire address

        // *********************************
        // *** Email and digest settings ***
        // *********************************

        define('SMTP_FROM_NAME', '${config.notifyMsg.fromName}');
        define('SMTP_FROM_ADDRESS', '${config.notifyMsg.fromAddr}');
        // Name, address and subject for sending outgoing mail. This applies
        // to password reset notifications, digest emails and any other mail.

        define('DIGEST_SUBJECT', '${config.notifyMsg.subject}');
        // Subject line for email digests

        define('SMTP_SERVER', '${config.notifyMsg.smtpServer}');
        // Hostname:port combination to send outgoing mail (i.e. localhost:25).
        // Blank - use system MTA.

        define('SMTP_LOGIN', '${config.notifyMsg.smtpLogin}');
        define('SMTP_PASSWORD', '${config.notifyMsg.smtpPassword}');
        // These two options enable SMTP authentication when sending
        // outgoing mail. Only used with SMTP_SERVER.

        define('SMTP_SECURE', '${config.notifyMsg.smtpSecure}');
        // Used to select a secure SMTP connection. Allowed values: ssl, tls,
        // or empty.

        // ***************************************
        // *** Other settings (less important) ***
        // ***************************************

        // TODO: How to handle ttrss updates?
        define('CHECK_FOR_NEW_VERSION', false);
        // Check for new versions of tt-rss automatically.

        define('DETECT_ARTICLE_LANGUAGE', false);
        // Detect article language when updating feeds, presently this is only
        // used for hyphenation. This may increase amount of CPU time used by
        // update processes, disable if necessary (i.e. you are being billed
        // for CPU time).

        define('ENABLE_GZIP_OUTPUT', false);
        // Selectively gzip output to improve wire performance. This requires
        // PHP Zlib extension on the server.
        // Enabling this can break tt-rss in several httpd/php configurations,
        // if you experience weird errors and tt-rss failing to start, blank pages
        // after login, or content encoding errors, disable it.

        define('PLUGINS', 'auth_internal, note, updater');
        // Comma-separated list of plugins to load automatically for all users.
        // System plugins have to be specified here. Please enable at least one
        // authentication plugin here (auth_*).
        // Users may enable other user plugins from Preferences/Plugins but may not
        // disable plugins specified in this list.
        // Disabling auth_internal in this list would automatically disable
        // reset password link on the login form.

        define('LOG_DESTINATION', 'sql');
        // Log destination to use. Possible values: sql (uses internal logging
        // you can read in Preferences -> System), syslog - logs to system log.
        // Setting this to blank uses PHP logging (usually to http server
        // error.log).

        define('CONFIG_VERSION', 26);
        // Expected config version. Please update this option in config.php
        // if necessary (after migrating all new options from this file).

        // vim:ft=php
  '';

  ttrssRoot = pkgs.stdenv.mkDerivation rec {
    name = "ttrss-1.12";

    src = pkgs.fetchurl {
      url = http://github.com/gothfox/Tiny-Tiny-RSS/archive/1.12.tar.gz;
      sha256 = "1bjj66yc5wlra7zd2bkmqsh9rwnrry92qclg9gwm75l6aw653l85";
    };

    installPhase = ''
      ensureDir $out
      cp -r * $out
      cp ${ttrssConfig} $out/config.php
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

    <Directory ${ttrssRoot}>
        Order allow,deny
        Allow from all
        DirectoryIndex index.php
        Options None
    </Directory>

    Alias ${config.urlPrefix}/feed-icons ${config.stateDir}/feed-icons

    <Directory ${config.stateDir}/feed-icons>
        Order allow,deny
        Allow from all
        Options None
    </Directory>
  '';

  documentRoot = if config.urlPrefix == "" then ttrssRoot else null;

  enablePHP = true;

  extraPath = let ttrss = ttrssRoot; in [ ttrss ];

  options = {
    siteHostName = mkOption {
      default = throw "You must specify `siteHostName`.";
      example = "example.org";
      description = "The host on which this TTRSS instance is hosted.";
    };

    siteURL = mkOption {
      default = "http://${config.siteHostName}/${config.urlPrefix}";
      example = "http://example.org/tt-rss/";
      description = ''
        The full URL to the TTRSS installation.
      '';
    };

    urlPrefix = mkOption {
      default = "";
      example = "ttrss";
      description = ''
        Full URL of your tt-rss installation. This should be set to the              
        location of tt-rss directory, e.g. http://example.org/tt-rss/                
        You need to set this option correctly otherwise several features             
        including PUSH, bookmarklets and browser integration will not work properly. 
      '';
    };

    cryptKey = mkOption {
      default = "";
      description = ''
        Key used for encryption of passwords for password-protected feeds
        in the database. A string of 24 random characters. If left blank, encryption
        is not used. Requires mcrypt functions.
        Warning: changing this key will make your stored feed passwords impossible
        to decrypt.
      '';
    };

    notifyContact = mkOption {
      default = serverInfo.serverConfig.adminAddr;
      example = "admin@example.com";
      description = "Email address to send new user notifications to.";
    };

    notifyMsg = {
      fromName = mkOption {
        default = "Tiny Tiny RSS";
        description = "From-name in 24h digest.";
      };

      fromAddr = mkOption {
        default = "noreply@${config.siteHostName}";
        description = "From-address in 24h digest.";
      };

      subject = mkOption {
        default = "[tt-rss] New headlines for last 24 hours";
        description = "Subject line in 24h digest.";
      };

      smtpServer = mkOption {
        default = "";
        example = "example.com:25";
        description = ''
          Send messages through this server. If empty, use system MTA.
        '';
      };

      smtpLogin = mkOption {
        default = "";
        description = ''
          Login for SMTP server. Not required if using system MTA.
        '';
      };

      smtpPassword = mkOption {
        default = "";
        description = ''
          Password for SMTP server. Not required if using system MTA.
        '';
      };

      smtpSecure = mkOption {
        default = "";
        example = "tls";
        description = ''
          Select a secure SMTP connect. Allowed values: ssl, tls, or empty.
        '';
      };
    };

    dbType = mkOption {
      default = "postgres";
      example = "mysql";
      description = "Database type.";
    };

    dbName = mkOption {
      default = "ttrss";
      description = "Name of the database that holds the TTRSS data.";
    };

    dbServer = mkOption {
      default = ""; # use a Unix domain socket
      example = "10.0.2.2";
      description = ''
        The location of the database server.  Leave empty to use a
        database server running on the same machine through a Unix
        domain socket.
      '';
    };

    dbPort = mkOption {
      default = ""; # use default port
      description = ''
        The connection port of the database server.
      '';
    };

    dbUser = mkOption {
      default = "ttrss";
      description = "The user name for accessing the database.";
    };

    dbPassword = mkOption {
      default = "";
      example = "foobar";
      description = ''
        The password of the database user.  Warning: this is stored in
        cleartext in the Nix store!
      '';
    };

    stateDir = mkOption {
      default = "/var/ttrss";
      description = ''
        Local storage directory for TTRS. Used for locks, cache, etc...
      '';
    };
  };

  startupScript = pkgs.writeScript "ttrss_startup.sh" ''
    # Initialise the database automagically if we're using a Postgres
    # server on localhost.
    ${(optionalString (config.dbType == "postgres" && config.dbServer == "") ''
      if ! ${pkgs.postgresql}/bin/psql -l | grep -q ' ${config.dbName} ' ; then
          ${pkgs.postgresql}/bin/createuser --no-superuser --no-createdb --no-createrole "${config.dbUser}" || true
          ${pkgs.postgresql}/bin/createdb "${config.dbName}" -O "${config.dbUser}"
          ${pkgs.postgresql}/bin/psql -U "${config.dbUser}" "${config.dbName}" < "${ttrssRoot}/schema/ttrss_schema_pgsql.sql"
      fi
      '')}

    # Copy the data directories into place.
    if [ ! -e "${config.stateDir}" ]; then
      mkdir -p "${config.stateDir}"
      cp -r "${ttrssRoot}/lock" "${config.stateDir}/lock"
      cp -r "${ttrssRoot}/cache" "${config.stateDir}/cache"
      cp -r "${ttrssRoot}/feed-icons" "${config.stateDir}/feed-icons"
      chmod -R u+w "${config.stateDir}"
      chown -R "${serverInfo.serverConfig.user}" "${config.stateDir}"
    fi
    '';
}
