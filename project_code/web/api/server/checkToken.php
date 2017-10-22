<?php
// uniquement pendant les test :
// header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
header('Access-Control-Allow-Methods: GET, POST');

// Connection data (server_address, database, name, poassword)
require_once ("cnct.php");
$conn = new PDO("mysql:host=".HOST."; dbname=".NAME, USER, PASS);
$conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);


if ($_SERVER['REQUEST_METHOD'] === 'POST') 
 {
 	$input = file_get_contents('php://input');
 	$jsonObj = json_decode($input);

	$user = $jsonObj->user;
	$token = $jsonObj->token;
	
/*	

*/
		try {
			$sql = "SELECT id FROM taf WHERE id LIKE'".$user."TOKEN%' AND data='".$token."' LIMIT 1";
			$select = $conn->query($sql, PDO::FETCH_OBJ);
			while($row = $select->fetch()) {
				$id_db = $row->id; 
			}
		}
		catch(PDOException $e) {
			echo '{"Caught exception": "'.$e->getMessage().'"}';
			$conn = null;
			die;
		}
	
		if ($id_db != "") {
			try {
				$dayhour_sc = date('Y-m-d H:i:s');
				$sql = "UPDATE taf SET dayhour='".$dayhour_sc."' WHERE id='".$id_db."'";
				$count = $conn->exec($sql);
				if ($count==1) echo '{"connected":true}';
				else echo '{"Caught exception": "update problem"}';
			}
			catch(PDOException $e) {
				echo '{"Caught exception": "'.$e->getMessage().'"}';
				$conn = null;
				die;
			}

			
		}
		else {
			echo '{"connected":false}';
		}

 }
 else
 {
 	echo '{"Caught exception":"method execpetion"}';
 }
 
 $conn = null;
?>