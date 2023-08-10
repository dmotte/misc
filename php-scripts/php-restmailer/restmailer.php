<?php

/**
 * php-restmailer v1.1.2
 * by dmotte
 * https://github.com/dmotte/misc/tree/main/php-scripts/php-restmailer
 */

//////////////////// BEGIN CONFIGURATION ////////////////////

$cfg = [];

$cfg['auth_username'] = 'admin';
$cfg['auth_password'] = 'changeme';

//////////////////// END CONFIGURATION ////////////////////

function diemsg(string $msg, int $response_code = 500)
{
    http_response_code($response_code);
    die($msg . PHP_EOL);
}

header('Content-Type: text/plain');

// Basic authentication
if (
    !isset($_SERVER['PHP_AUTH_USER']) ||
    !isset($_SERVER['PHP_AUTH_PW']) ||
    $_SERVER['PHP_AUTH_USER'] !== $cfg['auth_username'] ||
    $_SERVER['PHP_AUTH_PW'] !== $cfg['auth_password']
) {
    header('WWW-Authenticate: Basic realm="Authentication required"');
    diemsg('Please fill in the correct login details', 401);
}

$data = null;

if (
    isset($_GET['to']) &&
    isset($_GET['subject']) &&
    isset($_GET['message'])
)
    $data = $_GET;
else if (
    isset($_POST['to']) &&
    isset($_POST['subject']) &&
    isset($_POST['message'])
)
    $data = $_POST;
else if (
    isset($_GET['to']) &&
    isset($_GET['subject'])
) {
    $data = $_GET;

    $req_body = file_get_contents('php://input');
    if ($req_body === false) diemsg('Cannot read the request body');

    $data['message'] = $req_body;
} else if ($_SERVER['CONTENT_TYPE'] === 'application/json') {
    $req_body = file_get_contents('php://input');
    if ($req_body === false) diemsg('Cannot read the request body');

    $req_object = json_decode($req_body, true);
    if (is_null($req_object)) diemsg('Error while parsing the request body');

    if (
        isset($req_object['to']) &&
        isset($req_object['subject']) &&
        isset($req_object['message'])
    )
        $data = $req_object;
}

if (is_null($data))
    diemsg('Cannot determine request type');

if (!mail(
    $data['to'],
    $data['subject'],
    $data['message'],
    $data['additional_headers'] ?? [],
    $data['additional_params'] ?? '',
))
    diemsg('Error sending e-mail');
