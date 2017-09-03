<?php
// uniquement pendant les test :
//header('Access-Control-Allow-Origin: *');
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
			echo '{"connected":true}';
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