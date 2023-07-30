<?php

/**
 * php-backupper v1.1.1
 * by dmotte
 * https://github.com/dmotte/php-backupper
 */

//////////////////// BEGIN CONFIGURATION ////////////////////

$cfg = [];

$cfg['auth_username'] = 'admin';
$cfg['auth_password'] = 'changeme';

$cfg['src_dir'] = '.'; // The directory to backup
$cfg['arch_format'] = 'tar.gz'; // The backup archive format ('tar.gz' or 'zip')

$cfg['maint_file_name'] = 'maintenance.php';
$cfg['htaorig_file_name'] = '.htaccess.original';

//////////////////// END CONFIGURATION ////////////////////

function diemsg(string $msg, int $response_code = 500)
{
    http_response_code($response_code);
    die($msg . PHP_EOL);
}

$script_basename = basename(__FILE__);

$maint_file_path = $cfg['src_dir'] . '/' . $cfg['maint_file_name'];
$maint_file_content = <<<HEREDOC
<?php http_response_code(503); ?>
<h1>Website under maintenance</h1>
It will be back shortly.
HEREDOC;

$hta_file_path = $cfg['src_dir'] . '/' . '.htaccess';
$hta_file_content = <<<HEREDOC
RewriteEngine On
RewriteCond %{REQUEST_URI} !/$script_basename$
RewriteRule .* {$cfg['maint_file_name']} [L]
HEREDOC;

if (str_contains(PHP_SAPI, 'cgi')) // If PHP is running under CGI/FastCGI
    $hta_file_content .= PHP_EOL .
        'SetEnvIf Authorization .+ HTTP_AUTHORIZATION=$0';

$htaorig_file_path = $cfg['src_dir'] . '/' . $cfg['htaorig_file_name'];

// Make sure the script can handle large directories
ini_set('max_execution_time', 600); // 10 minutes
ini_set('memory_limit', '1024M'); // 1 GB

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

if (!isset($_GET['action']))
    diemsg('action parameter not provided');

switch ($_GET['action']) {
    case 'maint-on':
        if (file_exists($maint_file_path))
            diemsg('Maintenance mode is already enabled');

        if (file_exists($htaorig_file_path))
            diemsg('Cannot enable maintenance mode: the ' .
                $cfg['htaorig_file_name'] . ' file already exists');

        if (file_exists($hta_file_path))
            copy($hta_file_path, $htaorig_file_path);
        file_put_contents($hta_file_path, $hta_file_content);

        file_put_contents($maint_file_path, $maint_file_content);
        break;

    case 'maint-off':
        if (!file_exists($maint_file_path))
            diemsg('Maintenance mode is already disabled');
        if (file_get_contents($maint_file_path) !== $maint_file_content)
            diemsg('Cannot disable maintenance mode: the ' .
                $cfg['maint_file_name'] . ' file contains unexpected data');

        if (!file_exists($hta_file_path))
            diemsg('Cannot disable maintenance mode: the .htaccess file does not exist');
        if (file_get_contents($hta_file_path) !== $hta_file_content)
            diemsg('Cannot disable maintenance mode: the .htaccess file content is not recognized');

        if (file_exists($htaorig_file_path)) {
            copy($htaorig_file_path, $hta_file_path);
            unlink($htaorig_file_path);
        } else {
            unlink($hta_file_path);
        }

        unlink($maint_file_path);
        break;

    case 'backup':
        if (!file_exists($maint_file_path))
            diemsg('Maintenance mode is not enabled');

        // Final archive file extension
        $arch_ext_final = strtolower($cfg['arch_format']);
        if ($arch_ext_final !== 'tar.gz' && $arch_ext_final !== 'zip')
            diemsg('Unknown archive format');

        // Intermediate archive file extension
        $arch_ext_inter = $arch_ext_final === 'tar.gz' ? 'tar' : 'zip';

        $arch_file_path = tempnam(sys_get_temp_dir(), 'backupper') .
            '.' . $arch_ext_inter;

        // The PharData constructor automatically recognizes the archive format
        // from the file extension
        $phar = new PharData($arch_file_path);
        $phar->buildFromDirectory($cfg['src_dir']);

        if ($arch_ext_final === 'tar.gz') {
            $phar->compress(Phar::GZ); // This creates the .gz file
            unset($phar); // Close the archive
            unlink($arch_file_path); // Delete the uncompressed archive
            $arch_file_path .= '.gz';
        } else {
            unset($phar); // Close the archive
        }

        header('Content-Description: File Transfer');
        header('Content-Type: application/octet-stream');
        header('Content-Disposition: attachment; filename="backup.' .
            $arch_ext_final . '"');
        header('Content-Transfer-Encoding: binary');
        header('Expires: 0');
        header('Cache-Control: must-revalidate');
        header('Pragma: public');
        header('Content-Length: ' . filesize($arch_file_path));
        ob_clean();
        flush();
        readfile($arch_file_path);

        unlink($arch_file_path);
        break;

    default:
        diemsg('Unknown action');
}
