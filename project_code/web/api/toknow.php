<?php
require ("secureAPI.php"); 

// Point d'entrée de l'API
try {
    // Vérifier que la requête est en HTTPS en production
    if (!isset($_SERVER['HTTPS']) && $_SERVER['SERVER_NAME'] !== 'localhost') {
        http_response_code(426);
        echo json_encode(['error' => 'HTTPS required']);
        exit;
    }
    
    $api = new SecureAPI();
    $api->handleRequest();
	
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Internal server error']);
}



?>