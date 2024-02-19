# To learn more about how to use Nix to configure your environment
# see: https://developers.google.com/idx/guides/customize-idx-env
{ pkgs, ... }: {
  channel = "stable-23.11"; # "stable-23.11" or "unstable"
  # Use https://search.nixos.org/packages to  find packages
#
  packages = [
    pkgs.php81
    pkgs.php81Packages.composer
    pkgs.libsecret
    pkgs.nodejs
    pkgs.docker-compose
    pkgs.sqlite
  ];
  # Enable rootless docker
  services.docker.enable = true;
  # search for the extension on https://open-vsx.org/ and use "publisher.id"
  idx.extensions = [
    # "vscodevim.vim"
  ];

  # set up moodle when workspace is created
  idx.workspace.onCreate = {
    create-and-setup-project = "chmod +x .idx/setup.sh && .idx/setup.sh && echo 'Web URL: ' https://9002-$WEB_HOST && echo 'Mailpit URL: ' https://8025-$WEB_HOST";
  };

  idx.workspace.onStart = {
    start-mariadb = "docker start idx-db-1 > /dev/null";
    start-mailpit = "docker start mailpit > /dev/null";
  };
 
  env = {
    # Override nixos php settings
    PHP_INI_SCAN_DIR = "/home/user/project_idx_moodle/php_config";
  };

  # preview configuration, identical to monospace.json
  idx.previews = {
    enable = true;
    previews = [
      {
        command = ["/usr/bin/php" "-S" "0.0.0.0:$PORT"];
        cwd = "www";
        manager = "web";
        id = "web";
      }
    ];
  };
}
