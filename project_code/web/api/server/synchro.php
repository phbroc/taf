<?php
header('Access-Control-Allow-Methods: GET, POST');
header('Content-Type: application/json; charset=utf-8');
// attention, visiblement il faut faire gaffe à l'encodage

// Connection data (server_address, database, name, poassword)
require_once ("cnct.php");
$conn = new PDO("mysql:host=".HOST."; dbname=".NAME, USER, PASS);
$conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
// attention en fait il faut virer cette ligne ci-dessous, je ne sais pas pourquoi mais ça met la merde dans l'encodage.
//$conn->exec("SET CHARACTER SET utf8");      // Sets encoding UTF-8
$conn->beginTransaction();

 if ($_SERVER['REQUEST_METHOD'] === 'POST') 
 {
 	$input = file_get_contents('php://input');
 	
 	
 
 	$jsonObj = json_decode($input);
 	// moment de la synchro
 	$dayhour_sc = date('Y-m-d H:i:s');
 	
 	$result = "[";
 	// pour mémoriser tous ceux qui seront insérer ou mise à jour
	$proceededIds = "(";
	
	$token = $jsonObj->token;
	$dayhour_rq = $jsonObj->dayhour;
	$user_rq = $jsonObj->user;
	
	// test de la validité du token de connexion
	$data_db = "";
	try {
		$sql = "SELECT COUNT(*) FROM taf WHERE id LIKE'".$user_rq."TOKEN%' AND data='".$token."'";
		$select = $conn->query($sql, PDO::FETCH_OBJ);
	}
	catch(PDOException $e) {
		echo '[{"Caught exception": "'.$e->getMessage().'"}]';
		$conn = null;
		die;
	}

	if ($select->fetchColumn() > 0) {
    	$identified = true;
    }
    else {
    	$identified = false;
    }
	
	// fin du test de la validité du token de connexion
	
 	
 	// debut de la section qui traite les todo entrants
 	
 	if($identified & $jsonObj->data)
 	{	
    	$userCurrent = ""; // on va essayer de mémoriser l'utilisateur pour minimiser le calcul du prochain index, puisque normalement l'utilisateur ne change pas.
    	$userCurrentMaxindex = 0;
    	
    	while($item = array_shift($jsonObj->data))
		{
			// _js récupération des valeurs depuis le JSON
			$id_js = $item->id;
			$dayhour_js = $item->dayhour;
			$version_js = $item->version;
			// il faut juste échapper les simple quotes! et faire attention à l'encodage !
			if ($item->data)
			{
				//j'ai un problème de mauvais encodage avec cette fonction ci-dessous, qui devrait fonctionner pourtant...
				// en fait le problème était en haut de la page avec la connexion utf-8 à la bdd, je remets la ligne.
				$data_js_str = json_encode($item->data, JSON_UNESCAPED_UNICODE);
				$data_js_str_slashed = addcslashes($data_js_str, "'");
			}
			else {
				$data_js_str = "{}";
			}
			
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
				echo '[{"Caught exception": "'.$e->getMessage().'"}]';
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
						echo '[{"Caught exception": "'.$e->getMessage().'"}]';
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
							echo '[{"Caught exception": "'.$e->getMessage().'"}]';
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
						$sql = "INSERT INTO taf (id, dayhour, version, data, flags, cas, expiry) VALUES ('".$user.$nextIndex."', '".$dayhour_sc."', '".$nextVersion."', '".$data_js_str_slashed."', 0, 0, 0)";
						$count = $conn->exec($sql);
						if ($count ==1) 
						{
							$result .= '{"id":"'.$user.$nextIndex.'","dayhour":"'.$dayhour_sc.'","version":"'.$nextVersion.'","data":'.$data_js_str.'},';
							// il faut dire de mettre à jour (insérer) côté client celui qui avait un numéro de version déjà occupé
							$result .= '{"id":"'.$id_js.'","dayhour":"'.$dayhour_db.'","version":"'.$version_db.'","data":'.$data_db.'},';
							$proceededIds .= "'".$user.$nextIndex."','".$id_js."',";
						}
						else $result .= '{"id":"'.$id_js.'","dayhour":"'.$dayhour_js.'","version":"'.$version_js.'","data":'.$data_js_str.'},';
					}
					catch(PDOException $e) {
						echo '[{"Caught exception": "'.$e->getMessage().'"}]';
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
						$sql = "UPDATE taf SET data='".$data_js_str_slashed."', dayhour='".$dayhour_sc."', version='".$nextVersion."' WHERE id='".$id_js."'";
						$count = $conn->exec($sql);
						if ($count==1) {
							$result .= '{"id":"'.$id_js.'","dayhour":"'.$dayhour_sc.'","version":"'.$nextVersion.'","data":'.$data_js_str.'},';
							$proceededIds .= "'".$id_js."',";
						}
						else $result .= '{"id":"'.$id_js.'","dayhour":"'.$dayhour_js.'","version":"'.$version_js.'","data":'.$data_js_str.'},';
					}
					catch(PDOException $e) {
						echo '[{"Caught exception": "'.$e->getMessage().'"}]';
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
						$sql = "UPDATE taf SET data='".$data_js_str_slashed."', dayhour='".$dayhour_sc."', version='".$nextVersion."' WHERE id='".$id_js."'";
						$count = $conn->exec($sql);
						if ($count==1) {
							$result .= '{"id":"'.$id_js.'","dayhour":"'.$dayhour_sc.'","version":"'.$nextVersion.'","data":'.$data_js_str.'},';
							$proceededIds .= "'".$id_js."',";
						}
						else $result .= '{"id":"'.$id_js.'","dayhour":"'.$dayhour_js.'","version":"'.$version_js.'","data":'.$data_js_str.'},';
					}
					catch(PDOException $e) {
						echo '[{"Caught exception": "'.$e->getMessage().'"}]';
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
						$sql = "UPDATE taf SET data='".$data_db_slashed."', dayhour='".$dayhour_sc."', version='".$nextVersion."' WHERE id='".$id_js."'";
						$count = $conn->exec($sql);
						if ($count==1) {
							$result .= '{"id":"'.$id_js.'","dayhour":"'.$dayhour_sc.'","version":"'.$nextVersion.'","data":'.$data_db.'},';
							$proceededIds .= "'".$id_js."',";
						}
						else $result .= '{"id":"'.$id_js.'","dayhour":"'.$dayhour_js.'","version":"'.$version_js.'","data":'.$data_js_str.'},';
					}
					catch(PDOException $e) {
						echo '[{"Caught exception": "'.$e->getMessage().'"}]';
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
						$sql = "INSERT INTO taf (id, dayhour, version, data, flags, cas, expiry) VALUES ('".$id_js."', '".$dayhour_sc."', '".$nextVersion."', '".$data_js_str_slashed."', 0, 0, 0)";
						$count = $conn->exec($sql);
						if ($count ==1) {
							$result .= '{"id":"'.$id_js.'","dayhour":"'.$dayhour_sc.'","version":"'.$nextVersion.'","data":'.$data_js_str.'},';
							$proceededIds .= "'".$id_js."',";
						}
						else $result .= '{"id":"'.$id_js.'","dayhour":"'.$dayhour_js.'","version":"'.$version_js.'","data":'.$data_js_str.'},';
					}
					catch(PDOException $e) {
						echo '[{"Caught exception": "'.$e->getMessage().'"}]';
						$conn->rollBack();
						$conn = null;
						die;
					}
					
				}
				// s'agit-il d'une nouvelle demande de suppression (ce qui serait un bug), ne pas reinsérer un todo qui serait marquer comme à supprimer.
				else if ($version_js == "DD")
				{
					// ne pas travailler en base de données, mais reindiquer quand même que le todo n'existe plus.
					$result .= '{"id":"'.$id_js.'","dayhour":"'.$dayhour_sc.'","version":"'.'XX'.'","data":'.$data_js_str.'},';
				}
				else 
				{
					// situation de bug où l'item aurait disparu de la base de données, pas très grave il suffit de le reinsérer
					// DONE : INSERT et augmenter le numéro de version +1
					// TODO : ajouter une info que l'item est restauré en BDD ?
					$nextVersion = sprintf("%02d", 1+(int)$version_js);
					//echo "INSERT RESTAURE ".$id_js." v".$nextVersion.", ";
					try {
						$sql = "INSERT INTO taf (id, dayhour, version, data, flags, cas, expiry) VALUES ('".$id_js."', '".$dayhour_sc."', '".$nextVersion."', '".$data_js_str_slashed."', 0, 0, 0)";
						$count = $conn->exec($sql);
						if ($count ==1) {
							$result .= '{"id":"'.$id_js.'","dayhour":"'.$dayhour_sc.'","version":"'.$nextVersion.'","data":'.$data_js_str.'},';
							$proceededIds .= "'".$id_js."',";
						}
						else $result .= '{"id":"'.$id_js.'","dayhour":"'.$dayhour_js.'","version":"'.$version_js.'","data":'.$data_js_str.'},';
					}
					catch(PDOException $e) {
						echo '[{"Caught exception": "'.$e->getMessage().'"}]';
						$conn->rollBack();
						$conn = null;
						die;
					}
				}
			}
		}
	} 
	
	if (strlen($proceededIds)>1) $proceededIds = substr($proceededIds, 0, -1).")";
	else $proceededIds = "()";	
	
	// fin de la partie qui fait l'actualisation avec les todo entrant
	
	
	// partie pour récupérer tout le reste depuis la synchro
	
	
	
	if ($identified)
	{
		try {
			if ($proceededIds != "()")
				$sql = "SELECT id, dayhour, version, data FROM taf WHERE id>='".$user_rq."000000' AND id<='".$user_rq."999999' AND dayhour>='".$dayhour_rq."' AND id NOT IN ".$proceededIds." ORDER BY id ASC;";
			else
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
			echo '[{"Caught exception": "'.$e->getMessage().'"}]';
			$conn->rollBack();
			$conn = null;
			die;
		}
	}
	
	// fin de la partie qui récupère tout depuis la synchro
	
	
	// FIN
	
	if (strlen($result)>1) $result = substr($result, 0, -1)."]";
	else $result = "[]";
	
	echo $result;
	
 }
 else {
 	echo "[]";
 }

 
 
 $conn->commit();
 $conn = null;
?>