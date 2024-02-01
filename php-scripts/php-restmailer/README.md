# php-restmailer

:elephant: Simple PHP script that implements a **REST**ful API to **send e-mails**.

Inspired by [andrisro/REST-PHP-Mailer](https://github.com/andrisro/REST-PHP-Mailer).

Tested with _PHP 8.0.8_.

## Usage

Before uploading the script to your web server document directory, you may want to customize the configuration section. In particular, you should definitely **change the authentication credentials** and use a strong password.

Then you can use it like in the following examples:

```bash
curl 'https://admin:changeme@my-host.example.com/restmailer.php?to=my-recipient@example.com&subject=test-get&message=This%20is%20my%20GET%20test.'
```

```bash
curl -XPOST 'https://admin:changeme@my-host.example.com/restmailer.php' \
    -d 'to=my-recipient@example.com&subject=test-post&message=This%20is%20my%20POST%20test.'
```

```bash
ls | curl --data-binary @- 'https://admin:changeme@my-host.example.com/restmailer.php?to=my-recipient@example.com&subject=test-body'
```

```bash
curl -XPOST 'https://admin:changeme@my-host.example.com/restmailer.php' \
    -H 'Content-Type: application/json' \
    -d '{
        "to": "my-recipient@example.com",
        "subject": "test-json",
        "message": "This is my JSON test.",
        "additional_headers": {"Reply-To": "another-address@example.com"}
    }'
```

## Known issues

As stated [here](https://www.php.net/manual/en/features.http-auth.php#114877), if you are running PHP under **CGI/FastCGI** Apache, you should add this line to your `.htaccess` file to make authentication work:

```
SetEnvIf Authorization .+ HTTP_AUTHORIZATION=$0
```
