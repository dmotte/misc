# php-backupper

:elephant: Simple PHP script to **compress** and **download** a folder, with **authentication** and **maintenance mode** support.

This script is meant to be used with PHP running on an **Apache** web server. It uses the `.htaccess` file functionality to enable / disable the maintenance mode.

Tested with _PHP 8.1.3_.

## Usage

Before uploading the script to your web server document directory, you may want to customize the configuration section. In particular, you should definitely **change the authentication credentials** and use a strong password.

Then you can use it in the following manner:

```bash
curl http://admin:changeme@localhost:8080/backupper.php?action=maint-on
curl -fLo backup.tar.gz http://admin:changeme@localhost:8080/backupper.php?action=backup
curl http://admin:changeme@localhost:8080/backupper.php?action=maint-off
```

I have decided to split the behaviour into three different invocations so the user can control better what he is doing and check the logs in case of errors.

When you enable the maintenance mode, the script creates a `maintenance.php` file and an `.htaccess` file to redirect all the requests to it. If you want to know more about how the script works, just read it. It should be pretty straightforward.

## Known issues

As stated [here](https://www.php.net/manual/en/features.http-auth.php#114877), if you are running PHP under **CGI/FastCGI** Apache, you should add this line to your `.htaccess` file to make authentication work:

```
SetEnvIf Authorization .+ HTTP_AUTHORIZATION=$0
```

:warning: Unfortunately, when using `$cfg['arch_format'] = 'zip'`, the compression method is "**store**", so there's no compression at all.
