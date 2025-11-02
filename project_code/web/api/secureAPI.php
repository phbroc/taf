<?php
// pour debuguer avec cette class
require_once("simpleLog.php"); 
require_once("accessBD.php");
require("bearerAuth.php");


// Classe API principale
class SecureAPI {
    private $auth;
    private $user;
	private $log;
	private $bd;
    
    public function __construct() {
        $this->auth = new BearerAuth();
        
        // Authentifier l'utilisateur
        $this->user = $this->auth->authenticate();
        
        // Headers CORS et sécurité
        $this->setSecurityHeaders();
		
		$this->log = new Log('logs',Log::DEBUG);
		$this->bd = new AccessBD();
    }
    
    private function setSecurityHeaders() {
        header('Content-Type: application/json');
        header('Access-Control-Allow-Origin: *');
        header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
        header('Access-Control-Allow-Headers: *');
        
        // Headers de sécurité
        header('X-Content-Type-Options: nosniff');
        header('X-Frame-Options: DENY');
        header('X-XSS-Protection: 1; mode=block');
        
        // Gérer les requêtes OPTIONS (preflight)
        if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
            http_response_code(200);
            exit;
        }
    }
	
	private function generateRandomString($length = 10) {
		$characters = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
		$charactersLength = strlen($characters);
		$randomString = '';
		for ($i = 0; $i < $length; $i++) {
			$randomString .= $characters[rand(0, $charactersLength - 1)];
		}
		return $randomString;
	}
	
	private function getJsonInput() {
        $input = json_decode(file_get_contents('php://input'), true);
        
        if (json_last_error() !== JSON_ERROR_NONE) {
            $this->sendResponse(400, ['error' => 'Invalid JSON']);
        }
        
        return $input;
    }
    
    private function sendResponse($code, $data) {
        http_response_code($code);
		$json = html_entity_decode(json_encode(['data' => $data], JSON_PRETTY_PRINT));
        echo $json;
        exit;
    }
    
    public function handleRequest() {
        $method = $_SERVER['REQUEST_METHOD'];
        $path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
        
        // Router simple
        switch ($path) {
            case '/api/user.php':
                $this->handleUser($method);
				break;
			case '/api/toknow.php':
                if ($this->user) $this->handleToknow($method);
				else $this->sendResponse(401, ['error' => 'Not authentified']);
				break;
			default:
                $this->sendResponse(404, ['error' => 'Endpoint not found: '.$path]);
        }
    }
    
    private function handleUser($method) {
		switch ($method) {
            case 'GET':
                if ($this->user) {
					$data = array('user'=>$this->user);
					$this->sendResponse(200, $data);
				}
				else {
					$data = array('user' => null, 'token' => null);
					$this->sendResponse(200, $data);
				}
                break;
                
            case 'POST':
                $input = $this->getJsonInput();
                $this->log->logDebug("POST user... ".$input['user'].".");
                
                if ((isset($input['user'])) && (isset($input['password']))) {
					// check if password is correct
					$u = $this->bd->selectUserPassword($input['password']);
					if (is_object($u)) {
						if ((isset($input['newPassword'])) && ($input['newPassword'] != "") && ($u->id == $this->user)) {
							$resultat = $this->bd->updateUserPassword($this->user, $input['newPassword']);
							if ($resultat) {
								$data = array('success'=>true);
								$this->sendResponse(200, $data);
							}
							else {
								$data = array('success'=>false);
								$this->sendResponse(200, $data);
							}
						}
						else {
							$this->user = $u->id;
							$token = $this->generateRandomString(255);
							$resultat = $this->bd->insertToken($token, $u->id);
							if (!$resultat) $token = null;
							$data = array('user'=>$u->id, 'token'=>$token, 'email'=>$u->email);
							$this->sendResponse(200, $data);
						}
					}
					else {
						$this->user = null;
						$data = array('user' => null, 'token' => null, 'success'=>false);
						$this->sendResponse(200, $data);
					}
				}
				else if ((isset($input['email'])) && (isset($input['user']))) {
					if ($input['user'] == $this->user) {
						$resultat = $this->bd->updateUserEmail($this->user, $input['email']);
						if ($resultat) {
							$data = array('success'=>true);
							$this->sendResponse(200, $data);
						}
						else {
							$data = array('success'=>false);
							$this->sendResponse(200, $data);
						}
					}
					else {
						$data = array('success'=>false);
						$this->sendResponse(200, $data);
					}
				}
				else if ((!isset($input['password'])) && (isset($input['user']))) {
					// delete the token user
					$t = $this->auth->readToken();
					if ($t != null) $resultat = $this->bd->deleteToken($t);
					$data = array('success'=>true);
					$this->sendResponse(200, $data);
				}
				else if ((!isset($input['password'])) && (!isset($input['user']))) {
					$this->sendResponse(400, ['error' => 'password required']);
                }
				
				
                
                break;
                
            default:
                $this->sendResponse(405, ['error' => 'Method not allowed']);
		}
	}
	
	private function handleToknow($method) {
		switch ($method) {
            case 'GET':
			break;
			
			case 'POST':
				$input = $this->getJsonInput();
				$this->log->logDebug("handleToknow ".$input['dayhour']);
				if ((isset($input["toknows"])) && (isset($input["dayhour"]))) {
					// processing toknows to be responded since last synchro.
					$toknowsResponse = [];
					$toknowsSince = $this->bd->selectUserToknowsSince($this->user, $input["dayhour"]);
					if ($toknowsSince) {
						while ($toknowLine = $this->bd->nextLine($toknowsSince)) {
							array_push($toknowsResponse, $toknowLine);
						}
					}
					
					// reading and processing arriving toknows
					$count = 0;
					foreach($input["toknows"] as $toknow)
					{
						$this->log->logDebug("toknow ".$count." ".$toknow['id']);
						$count++;
						$existsToknow = $this->bd->selectToknow($toknow['id']);
						if (is_object($existsToknow)) {
							// complex case, first check dayhour to know wich of both is the newest
							$this->log->logDebug("dayhour ".$existsToknow->dayhour." ".$toknow['dayhour']);
							if ($existsToknow->dayhour < $toknow['dayhour']) {
								// ckeck for a new delete process
								if ($toknow['version'] == "DD") {
									$toknow['dayhour'] = date("Y-m-d H:i:s", time());
									$toknow['version'] = "XX";
									$toknow['title'] = ""; 
									$toknow['description'] = "";
									$toknow['end'] = null; 
									$this->bd->updateToknow(
													$toknow['id'], 
													$toknow['dayhour'], 
													$toknow['version'], 
													$toknow['title'], 
													$toknow['description'], 
													$toknow['done'], 
													$toknow['tag'], 
													$toknow['color'], 
													$toknow['end'], 
													$toknow['priority'], 
													$toknow['quick'], 
													$toknow['crypto']
													);
								}
								else if ($existsToknow->version != "XX") {
									if ($existsToknow->version < $toknow['version']) {
										// normal situation
										$this->log->logDebug("normal update");
										$this->bd->updateToknow(
													$toknow['id'], 
													$toknow['dayhour'], 
													$toknow['version'], 
													$toknow['title'], 
													$toknow['description'], 
													$toknow['done'], 
													$toknow['tag'], 
													$toknow['color'], 
													$toknow['end'], 
													$toknow['priority'], 
													$toknow['quick'], 
													$toknow['crypto']
													);
									}
									else {
										// potential conflict existsToknow was updated somewhere else
										// save existing data in a conflict comment.
										$toknow['title'] = $toknow['title']." [CONFLICT]";
										$toknow['description'] = $toknow['description']
																." [CONFLICT] "
																.$existsToknow->title." "
																.$existsToknow->description;
										$toknow['version'] = $existsToknow->version;
										$this->bd->updateToknow(
													$toknow['id'], 
													$toknow['dayhour'], 
													$toknow['version'], 
													$toknow['title'], 
													$toknow['description'], 
													$toknow['done'], 
													$toknow['tag'], 
													$toknow['color'], 
													$toknow['end'], 
													$toknow['priority'], 
													$toknow['quick'], 
													$toknow['crypto']
													);
									}
								}
							}
							else {
								// nothing to do, because tne newest is already in database
								// but may be the incoming toknow has highest version number ?
								// then it can be a conflict
								if ($existsToknow->version < $toknow['version']) {
									$toknow['title'] = $toknow['title']." [CONFLICT]".
									$toknow['description'] = $toknow['description']
																." [CONFLICT] "
																.$existsToknow->title." "
																.$existsToknow->description;
									$toknow['dayhour'] = $existsToknow->dayhour;
									$this->bd->updateToknow(
													$toknow['id'], 
													$toknow['dayhour'], 
													$toknow['version'], 
													$toknow['title'], 
													$toknow['description'], 
													$toknow['done'], 
													$toknow['tag'], 
													$toknow['color'], 
													$toknow['end'], 
													$toknow['priority'], 
													$toknow['quick'], 
													$toknow['crypto']
													);
								}
							}
						}
						else {
							// simple case, just insert a new toknow
							$this->bd->insertToknow(
													$toknow['id'], 
													$toknow['dayhour'], 
													$toknow['version'], 
													$toknow['title'], 
													$toknow['description'], 
													$toknow['done'], 
													$toknow['tag'], 
													$toknow['color'], 
													$toknow['end'], 
													$toknow['priority'], 
													$toknow['quick'], 
													$toknow['crypto']
													);
						}
					}
					
					
					
					$data = array('success'=>true, 'toknows'=>$toknowsResponse);
					$this->sendResponse(200, $data);
				}
				else {
					$this->sendResponse(400, ['error' => 'post has not toknows list']);
				}
				
			break;
		}
	}
	
	
}
     
?>