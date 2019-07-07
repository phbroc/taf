<?php
// uniquement pendant les test :
// header('Access-Control-Allow-Origin: http://localhost:53322');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');
header('Access-Control-Allow-Methods: GET, POST');

// Connection data (server_address, database, name, poassword)
require_once ("cnct.php");
$conn = new PDO("mysql:host=".HOST."; dbname=".NAME, USER, PASS);
$conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
$conn->beginTransaction();


 if ($_SERVER['REQUEST_METHOD'] === 'POST') 
 {
 	$input = file_get_contents('php://input');
 	$jsonObj = json_decode($input);
 	
 	

	$user = $jsonObj->user;
	$token = $jsonObj->token;
	
 	
		try {
			$sql = "SELECT COUNT(*) FROM taf WHERE id LIKE'".$user."TOKEN%' AND data='".$token."'";
			$select = $conn->query($sql, PDO::FETCH_OBJ);
		}
		catch(PDOException $e) {
			echo '{"Caught exception": "'.$e->getMessage().'"}';
			$conn = null;
			die;
		}
	
		if ($select->fetchColumn() > 0) {
			try {
				$sql = "DELETE FROM taf WHERE id LIKE'".$user."TOKEN%' AND data='".$token."'";
				$count = $conn->exec($sql);
				if ($count==1) echo '{"token":"XX"}';
				else echo '{"token": "error"}';
				// TODO : il faut indiquer à la BDD que ce token s'étent retiré, il faut aussi retirer ce token info de la liste des tokens mémorisés dans les data des todo marqués en version XX.
			}
			catch(PDOException $e) {
				echo '{"Caught exception": "'.$e->getMessage().'"}';
				$conn->rollBack();
				$conn = null;
				die;
			}
		}
		else {
			echo '{"token":"no token"}';
		}


 }
 else
 {
 	echo '{"Caught exception":"method execpetion"}';
 }


 
 $conn->commit();
 $conn = null;
?>