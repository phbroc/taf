<?php
// Connection data (server_address, database, name, poassword)
$hostdb = '';
$namedb = '';
$userdb = '';
$passdb = '';

$debug = "";

if (!empty($_POST['hostdb']) && !empty($_POST['namedb']) && !empty($_POST['userdb'])) {

	
	$hostdb = $_POST['hostdb'];
	$namedb = $_POST['namedb'];
	$userdb = $_POST['userdb'];
	$passdb = $_POST['passdb'];
	
	try {
		$conn = new PDO("mysql:host=".$hostdb."; dbname=".$namedb, $userdb, $passdb);
		$conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
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
		
		$sqlwd = "DROP TABLE IF EXISTS toknow";
		$conn->exec($sqlwd);
		
		$sqltd = "DROP TABLE IF EXISTS token";
		$conn->exec($sqltd);
		
		$sqlud = "DROP TABLE IF EXISTS user";
		$conn->exec($sqlud);
		
		$sqluc = "CREATE TABLE user ("
			."id CHAR(3), "
			."password CHAR(255), "
			."email CHAR(128), "
			."PRIMARY KEY(id)) "
			."ENGINE=InnoDB;";
		$conn->exec($sqluc);
		
		$sqltc = "CREATE TABLE token ("
			."id CHAR(255), "
			."user CHAR(3), "
			."expiry DATETIME, "
			."PRIMARY KEY (id), "
			."FOREIGN KEY (user) REFERENCES user(id) ) "
			."ENGINE=InnoDB;";
		$conn->exec($sqltc);
		
		$sqlwc = "CREATE TABLE toknow ("
			."id CHAR(10), "
			."dayhour DATETIME, "
			."version CHAR(2), "
			."title TINYTEXT, "
			."description TEXT, "
			."done BOOLEAN, "
			."tag VARCHAR(20), "
			."color TINYINT, "
			."end DATETIME, "
			."priority TINYINT, "
			."quick BOOLEAN, "
			."crypto BOOLEAN, "
			."PRIMARY KEY (id) ) "
			."ENGINE=InnoDB;";
		$conn->exec($sqlwc);
		
 		$conn = null;
	}
	
	
	
}
else {
	$debug .= "input required ! ";
}
?>

<html>
    <head>
      <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
      <title>INIT</title>
    </head>
    <body>
    	<h1>INIT</h1>
    	<p>Mise en place de la table, ATTENTION faire une fois car ça efface les données.</p>
      <form method="post">
        <p><b>serveur</b>: <input type="text" size="20" name="hostdb" required></p>
        <p><b>base</b>: <input type="text" size="20" name="namedb" required></p>
        <p><b>utilisateur</b>: <input type="text" size="20" name="userdb" required></p>
        <p><b>passe</b>: <input type="password" size="20" name="passdb"></p>
        <p><input type="submit"></p>
      </form>
      <hr/>
		
		<p><?php echo "log: ".$debug; ?></p>
    </body>
</html>