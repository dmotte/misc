<?php

//////////////////// BEGIN CONFIGURATION ////////////////////

$cfg = [];

$cfg['auth_username'] = 'admin';
$cfg['auth_password'] = 'changeme';

$cfg['uploads_dir'] = 'uploads';
$cfg['hta_protection'] = true;

$cfg['mail_to'] = false; // string or false
$cfg['mail_msg_prefix'] = '';
$cfg['mail_msg_suffix'] = '';

//////////////////// END CONFIGURATION ////////////////////

// Src: https://github.com/dmotte/misc/tree/main/snippets
function diemsg(string $msg, int $response_code = 500)
{
    http_response_code($response_code);
    die($msg . PHP_EOL);
}

// Src: https://github.com/dmotte/misc/tree/main/snippets
function mkdir_ine(string $path)
{
    return is_dir($path) || mkdir($path);
}

// Basic authentication
if (
    !isset($_SERVER['PHP_AUTH_USER']) ||
    !isset($_SERVER['PHP_AUTH_PW']) ||
    $_SERVER['PHP_AUTH_USER'] !== $cfg['auth_username'] ||
    $_SERVER['PHP_AUTH_PW'] !== $cfg['auth_password']
) {
    header('Content-Type: text/plain');
    header('WWW-Authenticate: Basic realm="Authentication required"');
    diemsg('Please fill in the correct login details', 401);
}

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    header('Content-Type: text/plain');

    if (
        !isset($_FILES['files']['name']) ||
        !is_array($_FILES['files']['name'])
    )
        diemsg('No files were uploaded');

    $files = [];
    for ($i = 0; $i < count($_FILES['files']['name']); $i++) {
        $f = [
            'name' => $_FILES['files']['name'][$i],
            'tmp_name' => $_FILES['files']['tmp_name'][$i],
            'error' => $_FILES['files']['error'][$i],
        ];
        $files[] = $f;
    }

    foreach ($files as $f) {
        // See https://www.php.net/manual/en/features.file-upload.errors.php
        if ($f['error'] != UPLOAD_ERR_OK)
            diemsg('Upload aborted because file ' . $f['name'] .
                ' has error code ' . $f['error']);
    }

    mkdir_ine($cfg['uploads_dir']);
    if ($cfg['hta_protection']) {
        $hta_file_path = $cfg['uploads_dir'] . '/' . '.htaccess';
        if (!file_exists($hta_file_path))
            file_put_contents(
                $hta_file_path,
                "Order deny,allow\nDeny from all\nSatisfy all"
            );
    }

    $str_datetime = date('Y-m-d-His');

    $dir = $cfg['uploads_dir'] . '/' . $str_datetime;
    mkdir_ine($dir);

    $summary = '';

    foreach ($files as $f) {
        if (move_uploaded_file($f['tmp_name'], $dir . '/' . $f['name']))
            $summary .= 'Successfully uploaded ' . $f['name'] . PHP_EOL;
        else
            $summary .= 'Warning: move_uploaded_file failed for ' .
                $f['name'] . PHP_EOL;
    }

    if ($cfg['mail_to'] && !mail(
        $cfg['mail_to'],
        "Funnel upload summary $str_datetime",
        $cfg['mail_msg_prefix'] . $summary . $cfg['mail_msg_suffix'],
    ))
        $summary .= 'Warning: failed to send summary e-mail' . PHP_EOL;

    die($summary);
}

?>
<!doctype html>
<html>

<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="color-scheme" content="light dark" />

    <title>Funnel</title>

    <style type="text/css">
        :root {
            color-scheme: light dark;
        }

        body,
        td,
        th {
            font-family: sans-serif;
        }

        #dialogMsg::backdrop {
            background-color: #1118;
            backdrop-filter: blur(3px);
        }
    </style>

    <script type="module">
        class App {
            static showModalMsg(msg = "") {
                const dialogMsg = document.getElementById("dialogMsg");

                if (msg === "") {
                    dialogMsg.close();
                    return;
                }

                dialogMsg.textContent = msg;
                dialogMsg.showModal();
            }

            ////////////////////////////////////////////////////////////////////

            static body_onload() {
                window.addEventListener("error", (event) => {
                    this.showModalMsg(`ERROR: ${event.error}`);
                });

                window.addEventListener("unhandledrejection", (event) => {
                    this.showModalMsg(`ERROR: ${event.reason}`);
                });

                // Show the page body only when loaded, to prevent
                // the user from interacting early
                document.body.hidden = false;
            }

            static btnSubmit_onclick() {
                const formMain = document.getElementById("formMain"),
                    preStatus = document.getElementById("preStatus");

                const xhr = new XMLHttpRequest();

                xhr.upload.addEventListener("progress", (event) => {
                    this.showModalMsg("Uploading (" + (
                        (event.loaded / event.total) * 100
                    ).toFixed(2) + "%)...");
                });

                xhr.addEventListener("load", () => {
                    preStatus.textContent = "Response: " + xhr.status + " " +
                        xhr.statusText + "\n\n" + xhr.responseText;
                    this.showModalMsg();
                });

                xhr.addEventListener("abort", () => {
                    preStatus.textContent = "Request aborted";
                    this.showModalMsg();
                });
                xhr.addEventListener("error", () => {
                    preStatus.textContent = "Request error";
                    this.showModalMsg();
                });
                xhr.addEventListener("timeout", () => {
                    preStatus.textContent = "Request timeout";
                    this.showModalMsg();
                });

                this.showModalMsg("Sending request...");

                xhr.open("POST", "", true);
                xhr.send(new FormData(formMain));
            }
        }

        window.App = App;
    </script>
</head>

<body hidden onload="App.body_onload()">
    <h1>Funnel</h1>

    <p>
    <form id="formMain" method="POST" enctype="multipart/form-data">
        <input type="file" name="files[]" multiple />
        <input type="button" id="btnSubmit" value="Submit"
            onclick="App.btnSubmit_onclick()" />
    </form>
    </p>

    <p>
    <pre id="preStatus">Ready</pre>
    </p>

    <dialog id="dialogMsg" closedby="none"></dialog>
</body>

</html>