<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST');
header('Access-Control-Allow-Headers: X-Requested-With');
header('Access-Control-Allow-Credentials: true');
header('Content-Type: application/json');
// Connection data (server_address, database, name, poassword)
$hostdb = 'localhost';
$namedb = 'test';
$userdb = 'root';
$passdb = '****';

$conn = new PDO("mysql:host=$hostdb; dbname=$namedb", $userdb, $passdb);
$conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
$conn->exec("SET CHARACTER SET utf8");      // Sets encoding UTF-8
$conn->beginTransaction();

/*
 if(empty($_POST['dayhour'])) 
 {
 	echo '["Caught exception":"no dayhour"]';
 	$conn->rollBack();
 	$conn = null;
 	die;
 }
 else if(empty($_POST['user'])) 
 {
 	echo '["Caught exception":"no user"]';
 	die;
 }
 else 
 {
 
 	$dayhour_rq = $_POST['dayhour'];
	$user_rq =  $_POST['user'];
	*/
 	
 	$dayhour_rq = '2017-01-01 12:00:00';
	$user_rq =  'PBD';
 	
 	$result = "[";
 	//if($_POST['data']) 
 	if ($_SERVER['REQUEST_METHOD'] === 'POST')
 	{
 		$input = file_get_contents('php://input');
 		// moment de la synchro
 		$dayhour_sc = date('Y-m-d H:i:s');
 		
 			try 
 			{
 			//$jsonArr = json_decode($_POST['data']);
 			$jsonArr = json_decode($input);
 		    	
    		$userCurrent = ""; // on va essayer de mémoriser l'utilisateur pour minimiser le calcul du prochain index, puisque normalement l'utilisateur ne change pas.
    		$userCurrentMaxindex = 0;
    	
    		//while($item = array_shift($jsonArr))
    		while($item = array_shift($jsonArr->data))
			{
				// _js récupération des valeurs depuis le JSON
				$id_js = $item->id;
				$dayhour_js = $item->dayhour;
				$version_js = $item->version;
				$data_js_str = json_encode((array)$item->data);
			
				// _db récupération des valeurs depuis la BDD
				$version_db = "";
				// premièrement retrouver si l'id existe déjà
				try {
					$sql = "SELECT dayhour, version, data FROM taf WHERE id='".$id_js."'";
					$select = $conn->query($sql, PDO::FETCH_OBJ);
					while($row = $select->fetch()) {
    					$dayhour_db = $row->dayhour;
    					$version_db = $row->version;
    					$data_db = $row->data; 
  					}
				}
				catch(PDOException $e) {
  					echo '["Caught exception": "'.$e->getMessage().'"]';
  					$conn->rollBack();
 					$conn = null;
  					die;
				}
			
				// cas où l'id existe déjà en BDD
				if ($version_db != "")
				{
					// il est déjà présent et...
					// est-ce qu'il est indiqué pour suppression ?
					if ($version_js == "DD")
					{
						// cas simple où on demande de supprimer un item
						// DONE : DELETE et renvoyer l'info qu'il a été supprimé grâce à une version = "XX"
						try {
							$sql = "DELETE FROM taf WHERE id='".$id_js."'";
							$count = $conn->exec($sql);
							if ($count==1) $result .= '{"id":"'.$id_js.'","dayhour":"'.$dayhour_sc.'","version":"'.'XX'.'","data":'.$data_js_str.'},';
							else $result .= '{"id":"'.$id_js.'","dayhour":"'.$dayhour_js.'","version":"'.'DD'.'","data":'.$data_js_str.'},';
						}
						catch(PDOException $e) {
  							echo '["Caught exception": "'.$e->getMessage().'"]';
  							$conn->rollBack();
 							$conn = null;
  							die;
						}
					}
					// ou est-ce que l'item à synchroniser n'a pas de version (il est nouveau)?
					else if ($version_js == "")
					{
						// conflit simple, cas où la création d'items s'est faite sur plusieurs appareils avant une synchro, il faut donc pousser le nouvel item au prochain rang possible pour cet utilisateur et initialiser sa version à 00, c'est un tout nouvel item
						$pos = strpos($id_js,"0");
						$user = substr($id_js,0,$pos);
						$index = substr($id_js,$pos,6);
				
						if ($user != $userCurrent)
						{
							$userCurrent = $user;
							try {
								$sql = "SELECT id FROM taf WHERE id>='".$user."000000' AND id<='".$user."999999' ORDER BY id DESC LIMIT 1;";
								$select = $conn->query($sql, PDO::FETCH_OBJ);
								while($row = $select->fetch()) {
									$userCurrentMaxindex = (int)substr($row->id,$pos);
								}
							}
							catch(PDOException $e) {
								echo '["Caught exception": "'.$e->getMessage().'"]';
								$conn->rollBack();
 								$conn = null;
								die;
							}
						}
				
						// DONE : INSERT et passer la version à "00"
						$userCurrentMaxindex += 1;
						$nextIndex = sprintf("%06d", $userCurrentMaxindex);
						$nextVersion = "00";
						//echo "INSERT REINDEX ".$user.$nextIndex." v".$nextVersion.", ";
						//$result .= '{"id":"'..'","dayhour":"'..'","version":"'..'","data":"'..'"},';
						try {
							$sql = "INSERT INTO taf (id, dayhour, version, data, flags, cas, expiry) VALUES ('".$user.$nextIndex."', '".$dayhour_sc."', '".$nextVersion."', '".$data_js_str."', 0, 0, 0)";
							$count = $conn->exec($sql);
							if ($count ==1) 
							{
								$result .= '{"id":"'.$user.$nextIndex.'","dayhour":"'.$dayhour_sc.'","version":"'.$nextVersion.'","data":'.$data_js_str.'},';
								// il faut dire de mettre à jour (insérer) côté client celui qui avait un numéro de version déjà occupé
								$result .= '{"id":"'.$id_js.'","dayhour":"'.$dayhour_db.'","version":"'.$version_db.'","data":'.$data_db.'},';
							}
							else $result .= '{"id":"'.$id_js.'","dayhour":"'.$dayhour_js.'","version":"'.$version_js.'","data":'.$data_js_str.'},';
						}
						catch(PDOException $e) {
							echo '["Caught exception": "'.$e->getMessage().'"]';
							$conn->rollBack();
 							$conn = null;
							die;
						}
						
				
					}
					// cas ou l'id est déjà présent mais en version égale ou inférieure dans la BDD
					else if ($version_js == $version_db)
					{
						// situation normale où il s'agit d'un update
						// DONE : UPDATE et passer la version à +1 de la version_js
						$nextVersion = sprintf("%02d", 1+(int)$version_js);
						//echo "UPDATE NORMAL ".$id_js." v".$nextVersion.", ";
						try {
							$sql = "UPDATE taf SET data='".$data_js_str."', dayhour='".$dayhour_sc."', version='".$nextVersion."' WHERE id='".$id_js."'";
							$count = $conn->exec($sql);
							if ($count==1) $result .= '{"id":"'.$id_js.'","dayhour":"'.$dayhour_sc.'","version":"'.$nextVersion.'","data":'.$data_js_str.'},';
							else $result .= '{"id":"'.$id_js.'","dayhour":"'.$dayhour_js.'","version":"'.$version_js.'","data":'.$data_js_str.'},';
						}
						catch(PDOException $e) {
							echo '["Caught exception": "'.$e->getMessage().'"]';
							$conn->rollBack();
 							$conn = null;
							die;
						}
						
					}
					else if ($version_js > $version_db)
					{
						// situation de conflit qui ne devrait pas arriver car la BDD est la seule à incrémenter les numéros de version
						// pas très grave comme la version JSON semble plus élevée, on ferait alors un UPDATE WARNING
						// DONE : UPDATE WARNING et passer la version à +1 de la version_js
						$nextVersion = sprintf("%02d", 1+(int)$version_js);
						//echo "UPDATE WARNING ".$id_js." v".$nextVersion.", ";
						// TODO : ajouter une info de warning
						try {
							$sql = "UPDATE taf SET data='".$data_js_str."', dayhour='".$dayhour_sc."', version='".$nextVersion."' WHERE id='".$id_js."'";
							$count = $conn->exec($sql);
							if ($count==1) $result .= '{"id":"'.$id_js.'","dayhour":"'.$dayhour_sc.'","version":"'.$nextVersion.'","data":'.$data_js_str.'},';
							else $result .= '{"id":"'.$id_js.'","dayhour":"'.$dayhour_js.'","version":"'.$version_js.'","data":'.$data_js_str.'},';
						}
						catch(PDOException $e) {
							echo '["Caught exception": "'.$e->getMessage().'"]';
							$conn->rollBack();
 							$conn = null;
							die;
						}	
					}
					else
					{
						// situation de conflit où l'item présent en BDD a un numéro de version plus élevé que celui qui est poussé via le JSON
						// il s'agit simplement une tentative de mettre à jour un item avec une version ancienne qui n'a pas bien été synchronisée
						// DONE : gérer le conflit, peut-être un UPDATE en plaçant les valeurs en conflit (obsolètes) uniquement dans un key-value spécial du JSON?
						$nextVersion = sprintf("%02d", 1+(int)$version_db);
						//echo "UPDATE CONFLIT ".$id_js." v".$nextVersion.", ";
						// TODO : placer les infos obsolètes dans data
						try {
							$sql = "UPDATE taf SET data='".$data_db."', dayhour='".$dayhour_sc."', version='".$nextVersion."' WHERE id='".$id_js."'";
							$count = $conn->exec($sql);
							if ($count==1) $result .= '{"id":"'.$id_js.'","dayhour":"'.$dayhour_sc.'","version":"'.$nextVersion.'","data":'.$data_db.'},';
							else $result .= '{"id":"'.$id_js.'","dayhour":"'.$dayhour_js.'","version":"'.$version_js.'","data":'.$data_js_str.'},';
						}
						catch(PDOException $e) {
							echo '["Caught exception": "'.$e->getMessage().'"]';
							$conn->rollBack();
 							$conn = null;
							die;
						}	
					}
				}
				// cas ou l'id n'existe pas en BDD
				else
				{
					// s'agit-il tout simplement d'un nouveau item à insérer?
					if ($version_js == "")
					{
						$nextVersion = "00";
						// DONE : faire un insert tout simple
						//echo "INSERT NORMAL ".$id_js." v".$nextVersion.", ";
						try {
							$sql = "INSERT INTO taf (id, dayhour, version, data, flags, cas, expiry) VALUES ('".$id_js."', '".$dayhour_sc."', '".$nextVersion."', '".$data_js_str."', 0, 0, 0)";
							$count = $conn->exec($sql);
							if ($count ==1) $result .= '{"id":"'.$id_js.'","dayhour":"'.$dayhour_sc.'","version":"'.$nextVersion.'","data":'.$data_js_str.'},';
							else $result .= '{"id":"'.$id_js.'","dayhour":"'.$dayhour_js.'","version":"'.$version_js.'","data":'.$data_js_str.'},';
						}
						catch(PDOException $e) {
							echo '["Caught exception": "'.$e->getMessage().'"]';
							$conn->rollBack();
 							$conn = null;
							die;
						}
						
					}
					else
					{
						// situation de bug où l'item aurait disparu de la base de données, pas très grave il suffit de le reinsérer
						// DONE : INSERT et augmenter le numéro de version +1
						// TODO : ajouter une info que l'item est restauré en BDD ?
						$nextVersion = sprintf("%02d", 1+(int)$version_js);
						//echo "INSERT RESTAURE ".$id_js." v".$nextVersion.", ";
						try {
							$sql = "INSERT INTO taf (id, dayhour, version, data, flags, cas, expiry) VALUES ('".$id_js."', '".$dayhour_sc."', '".$nextVersion."', '".$data_js_str."', 0, 0, 0)";
							$count = $conn->exec($sql);
							if ($count ==1) $result .= '{"id":"'.$id_js.'","dayhour":"'.$dayhour_sc.'","version":"'.$nextVersion.'","data":'.$data_js_str.'},';
							else $result .= '{"id":"'.$id_js.'","dayhour":"'.$dayhour_js.'","version":"'.$version_js.'","data":'.$data_js_str.'},';
						}
						catch(PDOException $e) {
							echo '["Caught exception": "'.$e->getMessage().'"]';
							$conn->rollBack();
 							$conn = null;
							die;
						}
					}
				}
			  
			}
	
	
	
	
			
		} 
		catch (Exception $e) 
		{
			echo '["Caught exception": "'.$e->getMessage().'"]';
		}
	}
	
	// partie pour récupérer tout le reste depuis la synchro
	
	
	
	
	try {
		$sql = "SELECT id, dayhour, version, data FROM taf WHERE id>='".$user_rq."000000' AND id<='".$user_rq."999999' AND dayhour>='".$dayhour_rq."' ORDER BY id ASC;";
		$select = $conn->query($sql, PDO::FETCH_OBJ);
		while($row = $select->fetch()) {
			$id_sl = $row->id;
			$dayhour_sl = $row->dayhour;
			$version_sl = $row->version;
			$data_sl = $row->data;
			
			$result .= '{"id":"'.$id_sl.'","dayhour":"'.$dayhour_sl.'","version":"'.$version_sl.'","data":'.$data_sl.'},';
		}
	}
	catch(PDOException $e) {
		echo '["Caught exception": "'.$e->getMessage().'"]';
		$conn->rollBack();
 		$conn = null;
		die;
	}
	
	
	
	// FIN
	
	if (strlen($result)>1) $result = substr($result, 0, -1)."]";
	else $result = "[]";
	
	echo $result;
// }
 $conn->commit();
 $conn = null;
?>