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
  ];


  # search for the extension on https://open-vsx.org/ and use "publisher.id"
  idx.extensions = [
    # "vscodevim.vim"
  ];

  idx.workspace.onCreate = {
    make-script-excutable="chmod +x setup.sh && ./setup.sh";
    create-and-setup-project="git clone --depth 1 -b MOODLE_403_STABLE https://github.com/moodle/moodle.git www && mkdir  php_config && cp $(find /nix/store -name 'php.ini' -path '*php-8.1.27/etc*' -print) php_config/php.ini && cp $(find /nix/store -name 'php.ini' -path '*php-with-extensions-8.1.27/lib*' -print) php_config/extensions.ini && sed -i 's/;max_input_vars = 1000/max_input_vars = 6000/' php_config/php.ini";};

  env = {
    # Overrride nixos php settings
    PHP_INI_SCAN_DIR = "/home/user/moodle/php_config";
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
