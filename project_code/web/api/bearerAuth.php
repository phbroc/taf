<?php
require_once("accessBD.php");
require_once("simpleLog.php"); 
// Classe pour gérer l'authentification Bearer Token
class BearerAuth {
    private $bd;
	private $token;
    
    public function __construct() {
		$this->bd = new AccessBD();
		$this->log = new Log('logs',Log::DEBUG);
	}
    
    public function authenticate() {
        $headers = $this->getAuthorizationHeader();
        
        if ($headers) {
            $this->token = $this->getBearerToken($headers);
			if ($this->token) {
				$user = $this->validateToken();
				if (!$user) {
					return null;
				}
				else {
					return $user;
				}
			}
			else {
				return null;
			}
        }
		else {
			return null;
		}
    }
    
    private function getAuthorizationHeader() {
        $headers = null;
        
        if (isset($_SERVER['Authorization'])) {
            $headers = trim($_SERVER["Authorization"]);
        } else if (isset($_SERVER['HTTP_AUTHORIZATION'])) {
            $headers = trim($_SERVER["HTTP_AUTHORIZATION"]);
        } elseif (function_exists('apache_request_headers')) {
            $requestHeaders = apache_request_headers();
            $requestHeaders = array_combine(array_map('ucwords', array_keys($requestHeaders)), array_values($requestHeaders));
            if (isset($requestHeaders['Authorization'])) {
                $headers = trim($requestHeaders['Authorization']);
            }
        }
        
        return $headers;
    }
    
    private function getBearerToken($headers) {
        if (!empty($headers)) {
            if (preg_match('/Bearer\s(\S+)/', $headers, $matches)) {
                return $matches[1];
            }
        }
        return null;
    }
    
    private function validateToken() {
		if ($this->token) {
			$user = $this->bd->selectUserToken($this->token);
			return $user;
		}
		else {
			return null;
		}
    }
    
    private function sendError($code, $message) {
        http_response_code($code);
        header('Content-Type: application/json');
        echo json_encode(['error' => $message]);
        exit;
    }
	
	public function readToken() {
		return $this->token;
	}
}

?>