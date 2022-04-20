<html>

<head>
    <title>reCAPTCHA v2 PHP Demo</title>
    <script src="https://www.google.com/recaptcha/api.js" async defer></script>
</head>

<body>
    <?php
    $recaptchaSecretKey = "SECRET_KEY_HERE";

    if (isset($_POST['g-recaptcha-response'])) {
        $username = $_POST['username'];
        $responseKey = $_POST['g-recaptcha-response'];
        $remoteIP = $_SERVER['REMOTE_ADDR'];

        $recaptchaResponseRaw = file_get_contents("https://www.google.com/recaptcha/api/siteverify?secret=$recaptchaSecretKey&response=$responseKey&remoteip=$remoteIP");
        $recaptchaResponseObj = json_decode($recaptchaResponseRaw);

        echo "<pre>$recaptchaResponseRaw</pre>";

        if ($recaptchaResponseObj->success)
            echo "<p>Verification succeeded. Username: <b>$username</b></p>";
        else
            echo "<p>Verification failed!</p>";
    }
    ?>

    <form method="POST">
        Your name: <input type="text" name="username" /><br />
        <br />
        <div class="g-recaptcha" data-sitekey="SITE_KEY_HERE"></div>
        <br />
        <input type="submit" value="Submit" />
    </form>
</body>

</html>