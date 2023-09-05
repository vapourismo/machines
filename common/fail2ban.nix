{...}: {
  services.fail2ban = {
    enable = true;
    maxretry = 5;
    ignoreIP = [
      "127.0.0.0/8"
      "10.0.0.0/8"
      "172.16.0.0/12"
      "192.168.0.0/16"
    ];
    jails = {
      nginx-http-auth = ''
        enabled = true
        port    = http,https
        logpath = %(nginx_error_log)s
      '';

      nginx-limit-req = ''
        enabled = true
        port    = http,https
        logpath = %(nginx_error_log)s
      '';

      nginx-botsearch = ''
        enabled  = true
        port     = http,https
        logpath  = %(nginx_error_log)s
      '';

      nginx-bad-request = ''
        enabled = true
        port    = http,https
        logpath = %(nginx_access_log)s
      '';
    };
  };

  services.openssh.settings.LogLevel = "VERBOSE";
}
