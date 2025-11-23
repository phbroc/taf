<?php
require("cnct.php");
require_once("simpleLog.php");

class AccessBD {
	private $conn;
	
	public function __construct() {
		$this->conn = new PDO("mysql:host=".HOST."; dbname=".NAME, USER, PASS);
		$this->conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
		$this->log = new Log('logs',Log::DEBUG);
	}
	
	public function nextObject($stmt) {
		if ($stmt != null) {
			try {
				$obj = $stmt->fetch(PDO::FETCH_OBJ);
				if (is_object($obj)) {
					return $obj;
				}
				else {
					return null;
				}
			} catch (PDOException $e) {
				return null;
			}	
		}
		else {
			return null;
		}
	}
	
	public function nextLine($stmt) {
		if ($stmt != null) {
			try {
				$line = $stmt->fetch(PDO::FETCH_ASSOC);
				if (isset($line['done'])) {
					if ($line['done'] == 0) $line['done'] = false;
					else $line['done'] = true;
				}
				if (isset($line['quick'])) {
					if ($line['quick'] == 0) $line['quick'] = false;
					else $line['quick'] = true;
				}
				if (isset($line['crypto'])) {
					if ($line['crypto'] == 0) $line['crypto'] = false;
					else $line['crypto'] = true;
				}
				if (isset($line['color'])) {
					$line['color'] = intval($line['color']);
				}
				if (isset($line['priority'])) {
					$line['priority'] = intval($line['priority']);
				}
				return $line;
			} catch (PDOException $e) {
				return null;
			}	
		}
		else {
			return null;
		}
	}
	
	public function insertUser($id, $password, $email) {
		try {
			$sql = 'INSERT INTO '.PREFIX.'user(id, password, email) VALUES(:id, :password, :email) ;';
			$stmt = $this->conn->prepare($sql);
			$stmt->bindValue(':id', $id);
			$stmt->bindValue(':password', $password);
			$stmt->bindValue(':email', $email);
			if ($stmt) {
				$stmt->execute();
				return true;
			}
			else {
				return null;
			}
		} catch (PDOException $e) {
			return null;
		}
	}
	
	public function selectUserId($id) {
		try {
			$sql = 'SELECT * FROM '.PREFIX.'user WHERE id = :id ;';
			$stmt = $this->conn->prepare($sql);
			$stmt->bindValue(':id', $id);
			if ($stmt) {
				$stmt->execute();
				$obj = $stmt->fetch(PDO::FETCH_OBJ);
				return $obj;
			}
			else {
				return null;
			}
		} catch (PDOException $e) {
			return null;
		}
	}
	
	public function updateUserPassword($id, $newPassword) {
		try {
			$sql = 'UPDATE '.PREFIX.'user SET password = :password, recovery = NULL, expiry = NULL WHERE id = :id ;';
			$stmt = $this->conn->prepare($sql);
			$stmt->bindValue(':id', $id);
			$stmt->bindValue(':password', $newPassword);
			if ($stmt) {
				$stmt->execute();
				return true;
			}
			else {
				return null;
			}
		} catch (PDOException $e) {
			$this->log->logDebug("updateUserPassword PDOException ".$e);
			return null;
		}
	}
	
	public function updateUserEmail($id, $email) {
		try {
			$sql = 'UPDATE '.PREFIX.'user SET email = :email WHERE id = :id ;';
			$stmt = $this->conn->prepare($sql);
			$stmt->bindValue(':id', $id);
			$stmt->bindValue(':email', $email);
			if ($stmt) {
				$stmt->execute();
				return true;
			}
			else {
				return null;
			}
		} catch (PDOException $e) {
			return null;
		}
	}
	
	public function updateUserErrors($id, $errors, $blocked) {
		try {
			$sql = 'UPDATE '.PREFIX.'user SET errors = :errors, blocked =:blocked  WHERE id = :id ;';
			$stmt = $this->conn->prepare($sql);
			$stmt->bindValue(':id', $id);
			$stmt->bindValue(':errors', $errors);
			$stmt->bindValue(':blocked', $blocked);
			if ($stmt) {
				$stmt->execute();
				return true;
			}
			else {
				return null;
			}
		} catch (PDOException $e) {
			return null;
		}
	}
	
	public function selecteUserRecovery($id, $recovery) {
		try {
			$sql = 'SELECT * FROM '.PREFIX.'user WHERE id = :id AND recovery = :recovery AND expiry > NOW();';
			$stmt = $this->conn->prepare($sql);
			$stmt->bindValue(':id', $id);
			$stmt->bindValue(':recovery', $recovery);
			if ($stmt) {
				$stmt->execute();
				$obj = $stmt->fetch(PDO::FETCH_OBJ);
				return $obj;
			}
			else {
				return null;
			}
		} catch (PDOException $e) {
			$this->log->logDebug("updateRecovery PDOException ".$e);
			return null;
		}
	}
	
	public function updateUserRecovery($id, $email, $recovery) {
		try {
			$sql = 'UPDATE '.PREFIX.'user SET recovery = :recovery, expiry =:expiry  WHERE id = :id AND email = :email ;';
			$stmt = $this->conn->prepare($sql);
			$stmt->bindValue(':id', $id);
			$stmt->bindValue(':email', $email);
			$stmt->bindValue(':recovery', $recovery);
			$expiry = date("Y-m-d H:i:s", strtotime("+1 hour", time()));
			$stmt->bindValue(':expiry', $expiry);
			if ($stmt) {
				$resultat = $stmt->execute();
				return $resultat;
			}
			else {
				return null;
			}
		} catch (PDOException $e) {
			$this->log->logDebug("updateRecovery PDOException ".$e);
			return null;
		}
	}
	
	public function selectUserPassword($id, $password) {
		try {
			$sql = 'SELECT * FROM '.PREFIX.'user WHERE id = :id AND password = :password ;';
			$stmt = $this->conn->prepare($sql);
			$stmt->bindValue(':id', $id);
			$stmt->bindValue(':password', $password);
			if ($stmt) {
				$stmt->execute();
				$obj = $stmt->fetch(PDO::FETCH_OBJ);
				if (is_object($obj)) {
					if (!$obj->blocked) {
						$resultat = $this->updateUserErrors($id, 0, false);
					}
					return $obj;
				}
				else {
					// check if user exists...
					$u = $this->selectUserId($id);
					if (is_object($u)) {
						// and check if too many errors...
						if ($u->blocked) {
							return $u;
						}
						else {
							$errors = 1 + $u->errors;
							if ($errors >= 5) {
								$resultat = $this->updateUserErrors($id, $errors, true);
								return null;
							}
							else {
								$resultat = $this->updateUserErrors($id, $errors, false);
								return null;
							}
						}
					}
					else return null;
				}
			}
			else {
				return null;
			}
		} catch (PDOException $e) {
			$this->log->logDebug("selectUserPassword PDOException ".$e);
			return null;
		}
	}
	
	public function insertToken($id, $user) {
		try {
			$sql = 'INSERT INTO '.PREFIX.'token(id, user, expiry) VALUES(:id, :user, :expiry) ;';
			$stmt = $this->conn->prepare($sql);
			$stmt->bindValue(':id', $id);
			$stmt->bindValue(':user', $user);
			$expiry = date("Y-m-d H:i:s", strtotime("+1 month", time()));
			$stmt->bindValue(':expiry', $expiry);
			if ($stmt) {
				$stmt->execute();
				return true;
			}
			else {
				return null;
			}
		} catch (PDOException $e) {
			$this->log->logDebug("insertToken PDOException ".$e);
			return null;
		}
	}
	
	public function deleteToken($id) {
		try {
			$sql = 'DELETE FROM '.PREFIX.'token WHERE id=:id ;';
			$stmt = $this->conn->prepare($sql);
			$stmt->bindValue(':id', $id);
			
			if ($stmt) {
				$stmt->execute();
				return true;
			}
			else {
				return null;
			}
		} catch (PDOException $e) {
			return null;
		}
	}
	
	public function deleteAllUserToken($user) {
		try {
			$sql = 'DELETE FROM '.PREFIX.'token WHERE user=:user ;';
			$stmt = $this->conn->prepare($sql);
			$stmt->bindValue(':user', $user);
			
			if ($stmt) {
				$stmt->execute();
				return true;
			}
			else {
				return null;
			}
		} catch (PDOException $e) {
			return null;
		}
	}
	
	public function selectUserToken($id) {
		try {
			$sql = 'SELECT user FROM '.PREFIX.'token WHERE id = :id AND expiry > NOW();';
			$stmt = $this->conn->prepare($sql);
			$stmt->bindValue(':id', $id);
			if ($stmt) {
				$stmt->execute();
				$obj = $stmt->fetch(PDO::FETCH_OBJ);
				if (is_object($obj)) {
					return $obj->user;
				}
				else {
					return null;
				}
			}
			else {
				return null;
			}
		} catch (PDOException $e) {
			return null;
		}
	}
	
	public function insertToknow($id, $dayhour, $version, $title, $description, $done, $tag, $color, $end, $priority, $quick, $crypto) {
		try {
			$sql = 'INSERT INTO '.PREFIX.'toknow(id, dayhour, version, title, description, done, tag, color, end, priority, quick, crypto) '
					.'VALUES(:id, :dayhour, :version, :title, :description, :done, :tag, :color, :end, :priority, :quick, :crypto); ';
			$stmt = $this->conn->prepare($sql);
			$stmt->bindValue(':id', $id);
			$stmt->bindValue(':dayhour', $dayhour);
			$stmt->bindValue(':version', $version);
			$stmt->bindValue(':title', $title);
			$stmt->bindValue(':description', $description);
			$stmt->bindValue(':done', $done);
			$stmt->bindValue(':tag', $tag);
			$stmt->bindValue(':color', $color);
			$stmt->bindValue(':end', $end);
			$stmt->bindValue(':priority', $priority);
			$stmt->bindValue(':quick', $quick);
			$stmt->bindValue(':crypto', $crypto);
			if ($stmt) {
				$stmt->execute();
				return true;
			}
			else {
				return null;
			}
		} catch (PDOException $e) {
			return null;
		}
	}
	
	public function selectToknow($id) {
		try {
			$sql = 'SELECT * FROM '.PREFIX.'toknow WHERE id = :id ;';
			$stmt = $this->conn->prepare($sql);
			$stmt->bindValue(':id', $id);
			if ($stmt) {
				$stmt->execute();
				$obj = $stmt->fetch(PDO::FETCH_OBJ);
				return $obj;
			}
			else {
				return null;
			}
		} catch (PDOException $e) {
			return null;
		}
	}
	
	public function selectUserToknowsSince($user, $dayhour) {
		try {
			$sql = 'SELECT * FROM '.PREFIX.'toknow WHERE (id LIKE :user OR id LIKE "SHR%") AND dayhour >= :dayhour ORDER BY dayhour DESC;';
			$stmt = $this->conn->prepare($sql);
			$stmt->bindValue(':user', $user."%");
			$stmt->bindValue(':dayhour', $dayhour);
			if ($stmt) {
				$stmt->execute();
				return $stmt;
			}
			else {
				return null;
			}
		} catch (PDOException $e) {
			return null;
		}
	}
	
	public function selectUserToknowMaxId($user) {
		try {
			$sql = 'SELECT id FROM '.PREFIX.'toknow WHERE id LIKE :user ORDER BY id DESC;';
			$stmt = $this->conn->prepare($sql);
			$stmt->bindValue(':user', $user."%");
			if ($stmt) {
				$stmt->execute();
				$obj = $stmt->fetch(PDO::FETCH_OBJ);
				if (is_object($obj)) {
					return $obj->id;
				}
				else {
					return null;
				}
			}
			else {
				return null;
			}
		} catch (PDOException $e) {
			return null;
		}
	}
	
	public function updateToknow($id, $dayhour, $version, $title, $description, $done, $tag, $color, $end, $priority, $quick, $crypto) {
		try {
			$sql = 'UPDATE '.PREFIX.'toknow SET '
				.'dayhour = :dayhour, '
				.'version=  :version, '
				.'title =  :title, '
				.'description =  :description, '
				.'done =  :done, '
				.'tag =  :tag, '
				.'color = :color, '
				.'end = :end, '
				.'priority = :priority, '
				.'quick = :quick, '
				.'crypto = :crypto '
				.'WHERE id = :id ; ';
			$stmt = $this->conn->prepare($sql);
			$stmt->bindValue(':id', $id);
			$stmt->bindValue(':dayhour', $dayhour);
			$stmt->bindValue(':version', $version);
			$stmt->bindValue(':title', $title);
			$stmt->bindValue(':description', $description);
			$stmt->bindValue(':done', $done);
			$stmt->bindValue(':tag', $tag);
			$stmt->bindValue(':color', $color);
			$stmt->bindValue(':end', $end);
			$stmt->bindValue(':priority', $priority);
			$stmt->bindValue(':quick', $quick);
			$stmt->bindValue(':crypto', $crypto);
			if ($stmt) {
				$stmt->execute();
				return true;
			}
			else {
				return null;
			}
		} catch (PDOException $e) {
			return null;
		}
	}
	
	public function deleteToknow($id) {
		try {
			$sql = 'DELETE FROM '.PREFIX.'toknow WHERE id = :id ;';
			$stmt = $this->conn->prepare($sql);
			$stmt->bindValue(':id', $id);
			if ($stmt) {
				$stmt->execute();
				return true;
			}
			else {
				return null;
			}
		} catch (PDOException $e) {
			return null;
		}
	}
	
}

?>
