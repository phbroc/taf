<?php
// Connection data (server_address, database, name, poassword)
$hostdb = '';
$namedb = '';
$userdb = '';
$passdb = '';

$debug = "";

if(!empty($_POST['hostdb']) && !empty($_POST['namedb']) && !empty($_POST['userdb']) && !empty($_POST['passdb'])) {

	
	$hostdb = $_POST['hostdb'];
	$namedb = $_POST['namedb'];
	$userdb = $_POST['userdb'];
	$passdb = $_POST['passdb'];
	
	try {
		$conn = new PDO("mysql:host=".$hostdb."; dbname=".$namedb, $userdb, $passdb);
		$conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
		$conn->beginTransaction();
	}
	catch(PDOException $e) {
  		$debug = " ".$e->getMessage();
	}
	
	if ($debug == "") {
	
		$debug .= "connexion OK... ";
		
		
 		
 		$monfichier=fopen("cnct.php","w");
		fputs($monfichier,"<?php\n"
		."// taf - connexion BDD\n"
		."define ('HOST',\"".$hostdb."\");\n"
		."define ('NAME',\"".$namedb."\");\n"
		."define ('USER',\"".$userdb."\");\n"
		."define ('PASS',\"".$passdb."\");\n"
		."?>");
		fclose ($monfichier);
		
		$table = "taf";
		
		$sqla = "DROP TABLE IF EXISTS ".$table;
		$conn->exec($sqla);
		
		$sqlb = "CREATE TABLE ".$table." (id VARCHAR(10), dayhour CHAR(19), version CHAR(2), data BLOB, flags INT, cas BIGINT UNSIGNED, expiry INT, primary key(id)) ENGINE=InnoDB";
		$conn->exec($sqlb);
		
		$dayhour = date('Y-m-d H:i:s');
		$sql = "INSERT INTO ".$table." (id, dayhour, version, data, flags, cas, expiry) VALUES ('TEST', '".$dayhour."', '--', 'INIT', 0, 0, 0)";
		$count = $conn->exec($sql);
		if ($count ==1) $debug .= " INSERT OK.";
		else $debug .= " INSERT KO :(.";			
		
		$conn->commit();
 		$conn = null;
		
	}
	
	
	
}
?>

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
    <head>
      <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
      <title>INIT</title>
    </head>
    <body>
    	<h1>INIT</h1>
    	<p>Mise en place de la table, ATTENTION faire une fois car ça efface les données.</p>
      <form method="post">
        <p><b>serveur</b>: <input type="text" size="20" name="hostdb"></p>
        <p><b>base</b>: <input type="text" size="20" name="namedb"></p>
        <p><b>utilisateur</b>: <input type="text" size="20" name="userdb"></p>
        <p><b>passe</b>: <input type="password" size="20" name="passdb"></p>
        <p><input type="submit"></p>
      </form>
      <hr/>
		
		<p><?php echo "log: ".$debug; ?></p>
    </body>
</html>