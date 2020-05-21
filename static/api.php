<?php
if(!isset($_GET['typ'])) { die("Nie podano typu"); }

$ciphering = "BF-CBC"; 
$iv_length = openssl_cipher_iv_length($ciphering); 
$options = 0; 
$encryption_iv = random_bytes($iv_length); 
$encryption_key = openssl_digest(php_uname(), 'MD5', TRUE); 
$decryption_iv = random_bytes($iv_length); 
$decryption_key = openssl_digest(php_uname(), 'MD5', TRUE); 

switch ($_GET['typ']) {
    case "encrypt":
        echo openssl_encrypt($_GET['txt'], $ciphering, $encryption_key, $options, $encryption_iv); 
        break;
    case "decrypt":
        echo openssl_decrypt($_GET['txt'], $ciphering, $decryption_key, $options, $encryption_iv); 
        break;
    case "odczyt":
        if(file_exists($_GET['plik'])) {
        echo file_get_contents($_GET['plik']);
        } else { echo "Incorrect request"; }
        break;

}



die();
?>