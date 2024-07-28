let 
  main = builtins.readFile ../_/id_rsa.pub;
in {
  "cf_account_id".publicKeys = [ main ];
  "cf_account_api".publicKeys = [ main ];
  "cf_account_email".publicKeys = [ main ];
  "glitchtip_key".publicKeys = [ main ];
  "nextcloud_mysql_password".publicKeys = [ main ];
  "nextcloud_mysql_root_password".publicKeys = [ main ];
  "vscode_hashed_password".publicKeys = [ main ];
}