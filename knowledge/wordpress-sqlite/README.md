# wordpress-sqlite

**WordPress** is a **web CMS** (_Content Management System_) that lets you create dynamic websites quickly and easily.

It has an internal **caching** system to speed-up page loading, which mitigates the performance loss compared to a static website.

There is also an official [WordPress Android app](https://play.google.com/store/apps/details?id=org.wordpress.android), which makes it easy to make changes to your website using your **smartphone**.

In this tutorial we will see how to install _WordPress_ using an **SQLite database** as storage backend.

> :warning: **Warning**: this setup is intended for **testing**, **development**, and **lightweight use cases** only. _SQLite_ lacks the performance, scalability, and concurrency management needed for production _WordPress_ websites. Use this setup at your own risk.

Tested on the following setup:

- A _Linux_ server
- _PHP_ version **8.1.3**
- _WordPress_ version **6.1**
- _WP SQLite DB WordPress plugin_ version **1.3.1**
  - GitHub permalink: https://github.com/aaemnnosttv/wp-sqlite-db/blob/5d8af6bd9906b9dc95a06c9009965548e1b0ae49/src/db.php
  - SHA256 checksum: `a4a4eb91ca3b2acb66a113b4c7d1b1b184ce284e7938083d4d2522743b369669`

## Install Tiny File Manager

First of all, download [**Tiny File Manager**](https://github.com/prasathmani/tinyfilemanager) from the following URL: https://raw.githubusercontent.com/prasathmani/tinyfilemanager/master/tinyfilemanager.php

If your website will also be visible to some other people, it is advised to **rename** the downloaded `tinyfilemanager.php` script to some random name, to prevent others from guessing it once it will be uploaded to the website.

Edit its configuration (which is placed at the beginning of the script itself) to have a **single read-write user** with a **strong password**. Example:

```php
$auth_users = array(
    // Warning: this is just an example! do NOT store the plain text password
    // here - put the hashed result instead. Also, use a really strong
    // password, not a simple one like this
    'admin' => password_hash('mypassword', PASSWORD_DEFAULT)
);

$readonly_users = array();
```

Then upload the script to your website **root folder**.

## Install WordPress

> **Note**: to make website management easier, we will install _WordPress_ in a **subdirectory** of the web hosting space, named `website`.

Using _Tiny File Manager_'s "Upload from URL" feature, download the latest **WordPress compressed archive** into the website root. The URL is the following:

```
https://wordpress.org/latest.zip
```

Using _Tiny File Manager_'s "UnZip" feature, **extract** the archive content to the website root. As a result, you should get a `wordpress` folder there.

**Rename** such `wordpress` folder to `website`.

**Remove** the _WordPress_ compressed archive from the website root.

Using _Tiny File Manager_'s "Upload from URL" feature, download the **WP SQLite DB WordPress plugin** (it's a single `db.php` file) into the `website/wp-content` directory. The URL is the following:

```
https://raw.githubusercontent.com/aaemnnosttv/wp-sqlite-db/master/src/db.php
```

This will make _WordPress_ use an **SQLite** database as storage backend.

**Rename** the `wp-config-sample.php` file to `wp-config.php`.

## Finalization and cleanup

**Delete the unnecessary files** from the _WordPress_ folder, such as `license.txt` and `readme.html`.

Now visit `https://<your-domain>/website` to **finalize the _WordPress_ installation**.

> **Warning**: once the website is created, **do NOT change its URL**, as that would break all the images, links and other stuff.

Since we installed _WordPress_ in the `website` subdirectory, we can create an `index.php` file in the website root with the following content, to **redirect** users to the website when they visit the root (`/`):

```php
<?php header('Location: /website/'); ?>Redirecting...
```

Now you can **remove the _Tiny File Manager_ script** from your website root.

## Tips and further steps

In order to keep your website management simple, it is advised to have a **single WordPress user** if you don't need multiple ones.

To prevent the website from breaking unexpectedly without your supervision, you might want to go to the _Dashboard_ &rarr; _Updates_ menu and click on `Switch to automatic updates for maintenance and security releases only`. This helps keep your website secure while minimizing disruptions. However, always remember to regularly back up your site and keep your _WordPress_ installation up to date.

As for the theme, **Twenty-Twenty Three** is a good choice, as it allows easy customization of all website elements. However, if it doesn't work for some reason, _Astra_ is a good alternative.

By default the _Home Page_ will show a list of the **most recent posts**. You can change this in the _Settings_ &rarr; _Reading_ screen.

If you want to keep your website as clean and simple as possible, you can avoid using _Posts_ or _Comments_, if they are not necessary; you can build a good showcase website using **Pages** only.

Same thing about _WordPress_ **plugins**: don't use any of them if not necessary.

You can also **protect** some **pages** with a **password**. If you use the same password for multiple pages, _WordPress_ will keep it in memory and the user won't have to re-type it for every protected page.

## Links

- [Wordpress with SQLite Tutorial - YouTube](https://www.youtube.com/watch?v=husGalol2QE)
- [Migrating WordPress - Advanced Administration Handbook - Developer.WordPress.org](https://wordpress.org/support/article/changing-the-site-url/)
