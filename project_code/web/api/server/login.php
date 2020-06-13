<?php
// uniquement pendant les test :
// header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
header('Access-Control-Allow-Methods: GET, POST');


// Connection data (server_address, database, name, poassword)
require_once ("cnct.php");

$uniqUserPass = "somepassword";

$conn = new PDO("mysql:host=".HOST."; dbname=".NAME, USER, PASS);
$conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
//$conn->exec("SET CHARACTER SET utf8");      // Sets encoding UTF-8
$conn->beginTransaction();

function generateRandomString($length = 10) {
    $characters = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    $charactersLength = strlen($characters);
    $randomString = '';
    for ($i = 0; $i < $length; $i++) {
        $randomString .= $characters[rand(0, $charactersLength - 1)];
    }
    return $randomString;
}


 if ($_SERVER['REQUEST_METHOD'] === 'POST') 
 {
 	$input = file_get_contents('php://input');
 	$jsonObj = json_decode($input);
 	
 	

	$user = $jsonObj->user;
	$pass = $jsonObj->pass;
	
	if ($pass == $uniqUserPass) {
 	
		$result = "{";
		$dayhour_sc = date('Y-m-d H:i:s');
		$data_new = generateRandomString(20);

		try {
			$sql = "SELECT id FROM taf WHERE id LIKE'".$user."TOKEN%' ORDER BY dayhour DESC LIMIT 1";
			$select = $conn->query($sql, PDO::FETCH_OBJ);
			while($row = $select->fetch()) {
				$id_db = $row->id; 
			}
		}
		catch(PDOException $e) {
			echo '{"Caught exception": "'.$e->getMessage().'"}';
			$conn->rollBack();
			$conn = null;
			die;
		}
	
		
		$nextId = $user."TOKEN";
		if ($id_db != "") {
			if ($id_db == $user."TOKEN9") $nextId .= "1";
			else $nextId .= (int)substr($id_db, strlen($id_db)-1, 1)+1;
		}
		else {
			$nextId .= "1";
		}
			
		try {
			$sql = "SELECT COUNT(*) FROM taf WHERE id ='".$nextId."'";
			$select = $conn->query($sql, PDO::FETCH_OBJ);
		}
		catch(PDOException $e) {
			echo '{"Caught exception": "'.$e->getMessage().'"}';
			$conn = null;
			die;
		}
		
		
	
		if ($select->fetchColumn() > 0) {		
			try {
				$sql = "UPDATE taf SET data='".$data_new."', dayhour='".$dayhour_sc."' WHERE id='".$nextId."'";
				$count = $conn->exec($sql);
				if ($count==1) $result .= '"token":"'.$data_new.'"';
				else $result .= '"Caught exception": "update error"';
			}
			catch(PDOException $e) {
				echo '{"Caught exception": "'.$e->getMessage().'"}';
				$conn->rollBack();
				$conn = null;
				die;
			}
		}
		else {
			try {
				$sql = "INSERT INTO taf  (id, dayhour, version, data, flags, cas, expiry) VALUES ('".$nextId."', '".$dayhour_sc."', 'ST', '".$data_new."', 0, 0, 0)";
				$count = $conn->exec($sql);
				if ($count==1) $result .= '"token":"'.$data_new.'"';
				else $result .= '"Caught exception": "insert error"';
			}
			catch(PDOException $e) {
				echo '{"Caught exception": "'.$e->getMessage().'"}';
				$conn->rollBack();
				$conn = null;
				die;
			}
		}
	
	
		echo $result."}";
		
		

//

	}
	else {
		echo '{"token":null}';
	}
	

 }
 else
 {
 	echo '{"Caught exception":"method execpetion"}';
 }

 //
 
 $conn->commit();
 $conn = null;
 
 
?>