{...}: {
  users.users.ole = {
    isNormalUser = true;

    group = "ole";
    extraGroups = ["wheel"];

    openssh.authorizedKeys.keys = [
      # Desktop
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDKKRTgvRNbWuT85F9/qKZy9cJ47bC7kZhEgDz/dC24F+WQC7sV+MrimPb7cuyRyL7YAgf5kebM97eUa1rMNYfX+avD17pCW/3bVu37VPN+s3UHECSFN0BNTT0D0sIWXHcJdZkoa2UUEMCPzzjBpOQLNtoUQhdkrwJIS7KMjw9DJWf6gCGzUEYW2mzhnIzL5OeBHD4IGLKaIzAANKxALDIugfUhB3WlMUidhlu1TyaXvqsJ7Vj2OfX2Dv75wZIjeBRZse4Yq9fMWjiUcZds88eBX6y7ts7zzv0jd1pbThc7PIQLOsHAOapOFElS6gZlLOf+9k9f9j3LPFi8xu07OZCP"
      # Self
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB6nFifbv41ZC+L5fJcaiihHb3pzFkX4FKhpjeuCuHxn root@fi1"
      # NuttenBook Pro
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO7vlc902QXTseSF7NsFy3CouUnWFQWDFy1EvS0CRD5q ole@ole-darwin.home"
      # Work Laptop
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJdlM4k1cHeROz7DBiTZxFpqj9Nesuf8bHM6scnSLXWs ole@Oles-MacBook-Pro.local"
    ];
  };

  users.groups.ole = {};
}
