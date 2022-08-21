{ ... }: {
  security.acme = {
    acceptTerms = true;
    defaults.email = "letsencrypt@vprsms.de";
  };
}
