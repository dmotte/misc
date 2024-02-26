<?php

$data = [
    '_SERVER' => [
        'REQUEST_TIME' => null,

        'REMOTE_ADDR' => null, 'REMOTE_PORT' => null,
        'SERVER_NAME' => null, 'SERVER_PORT' => null,

        'REQUEST_METHOD' => null,
        'REQUEST_URI' => null,
        'SERVER_PROTOCOL' => null,
    ],

    'getallheaders' => getallheaders(),
];

foreach ($data['_SERVER'] as $key => &$val) $val = $_SERVER[$key];

header('Content-Type: application/json');

die(json_encode($data));
