<?php
require("accessBD.php");

$debug = "";

if (!empty($_POST['id']) && !empty($_POST['password'])) {
	$debug .= "user creation... ";
	$id = trim($_POST['id']);
	$password = trim($_POST['password']);
	if (preg_match("/[A-Z]{3}/", $id)) {
		if (strlen($id) == 3) {
			$bd = new AccessBD();
			$resultat = $bd->insertUser($id, $password);
			if ($resultat) {
				$user = $bd->selectUserId($id);
				if ($user) {
					$debug .= "user ".$user->id." created. ";
				}
				else {
					$debug .= "probleme with user selection. ";
				}
			}
			else {
				$debug .= "probleme with insert user. ";
			}
		}
		else {
			$debug .= "id must be 3 chars max. ";
		}
	}
	else {
		$debug .= "id must have 3 caps. ";
	}
	
}
else {
	$debug .= "input required ! ";
}
?>

<html>
    <head>
      <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
      <title>INIT USER</title>
    </head>
    <body>
    	<h1>INIT USER</h1>
    	<p>Add new user.</p>
      <form method="post">
        <p><b>id</b>: <input type="text" size="3" name="id" maxlength="3" required></p>
        <p><b>password</b>: <input type="text" size="100" name="password" maxlength="255" required></p>
        <p><input type="submit"></p>
      </form>
      <hr/>
		
		<p><?php echo "log: ".$debug; ?></p>
    </body>
</html>