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
				return $line;
			} catch (PDOException $e) {
				return null;
			}	
		}
		else {
			return null;
		}
	}
	
	public function insertUser($id, $password) {
		try {
			$sql = 'INSERT INTO user(id, password) VALUES(:id, :password) ;';
			$stmt = $this->conn->prepare($sql);
			$stmt->bindValue(':id', $id);
			$stmt->bindValue(':password', $password);
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
			$sql = 'SELECT * FROM user WHERE id = :id ;';
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
			$sql = 'UPDATE user SET password = :password WHERE id = :id ;';
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
			return null;
		}
	}
	
	public function updateUserEmail($id, $email) {
		try {
			$sql = 'UPDATE user SET email = :email WHERE id = :id ;';
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
	
	public function selectUserPassword($password) {
		try {
			$sql = 'SELECT * FROM user WHERE password = :password ;';
			$stmt = $this->conn->prepare($sql);
			$stmt->bindValue(':password', $password);
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
	
	public function insertToken($id, $user) {
		try {
			$sql = 'INSERT INTO token(id, user, expiry) VALUES(:id, :user, :expiry) ;';
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
			return null;
		}
	}
	
	public function deleteToken($id) {
		try {
			$sql = 'DELETE FROM token WHERE id=:id ;';
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
	
	public function selectUserToken($id) {
		try {
			$sql = 'SELECT user FROM token WHERE id = :id AND expiry > NOW();';
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
			$sql = "INSERT INTO toknow(id, dayhour, version, title, description, done, tag, color, end, priority, quick, crypto) "
					."VALUES(:id, :dayhour, :version, :title, :description, :done, :tag, :color, :end, :priority, :quick, :crypto); ";
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
			$sql = 'SELECT * FROM toknow WHERE id = :id ;';
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
			$sql = 'SELECT * FROM toknow WHERE (id LIKE :user OR id LIKE "SHR%") AND dayhour >= :dayhour;';
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
	
	public function updateToknow($id, $dayhour, $version, $title, $description, $done, $tag, $color, $end, $priority, $quick, $crypto) {
		try {
			$sql = "UPDATE toknow SET "
				."dayhour = :dayhour, "
				."version=  :version, "
				."title =  :title, "
				."description =  :description, "
				."done =  :done, "
				."tag =  :tag, "
				."color = :color, "
				."end = :end, "
				."priority = :priority, "
				."quick = :quick, "
				."crypto = :crypto "
				."WHERE id = :id ; ";
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
			$sql = 'DELETE FROM toknow WHERE id = :id ;';
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