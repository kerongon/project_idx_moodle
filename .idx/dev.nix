# To learn more about how to use Nix to configure your environment
# see: https://developers.google.com/idx/guides/customize-idx-env
{ pkgs, ... }: {
  channel = "stable-23.11"; # "stable-23.11" or "unstable"
  # Use https://search.nixos.org/packages to  find packages
#
  packages = [
    pkgs.php81
    pkgs.php81Packages.composer
  ];

  env = {
    PHP_INI_SCAN_DIR = "/home/user/moodle/php_config";
  };
  
  # search for the extension on https://open-vsx.org/ and use "publisher.id"
  idx.extensions = [
    # "vscodevim.vim"
  ];
  # preview configuration, identical to monospace.json
  idx.previews = {
    # enable = true;
    # previews = [
    #   {
    #     command = ["/usr/bin/php" "-S" "0.0.0.0:$PORT"];
    #     cwd = "www";
    #     manager = "web";
    #     id = "web";
    #   }
    # ];
  };
}
