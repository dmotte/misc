# php-funnel

:elephant: Simple PHP script that lets you upload **multiple files** with a single HTTP `POST` request ([multipart formpost](https://everything.curl.dev/http/multipart)).

Tested with PHP _8.2.10_.

> **Warning**: be careful about the location of your `uploads_dir`; it **shouldn't be accessible** from the outside. If you are running PHP on an **Apache** web server, you can leverage the `hta_protection` feature of this script (which uses an `.htaccess` file), but putting uploaded files into the document root is still **strongly discouraged**.

## Usage

Before uploading the script to your web server document directory, you may want to customize the configuration section. In particular, you should definitely **change the authentication credentials** and use a strong password.

If you want the script to **send an e-mail automatically** when an upload is successful, set the `mail_to` config option to the recipient's address:

```php
$cfg['mail_to'] = 'alice@example.com';
```

Then you can use the script in the following manner:

```bash
curl -F 'files[]=@img01.jpg' -F 'files[]=@img02.jpg' \
    'https://admin:changeme@my-host.example.com/funnel.php'

date | curl -F 'files[]=@-;filename=date.txt' \
    'https://admin:changeme@my-host.example.com/funnel.php'
```

Or, in alternative, you can upload files manually from the **built-in Web UI**. To do that, just visit the script page with a web browser.

## Known issues

As stated [here](https://www.php.net/manual/en/features.http-auth.php#114877), if you are running PHP under **CGI/FastCGI** Apache, you should add this line to your `.htaccess` file to make authentication work:

```
SetEnvIf Authorization .+ HTTP_AUTHORIZATION=$0
```
