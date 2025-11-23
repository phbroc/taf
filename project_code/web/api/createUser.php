<?php
require("accessBD.php");

$debug = "";

if (!empty($_POST['id']) && !empty($_POST['password']) && !empty($_POST['email'])) {
	$debug .= "user creation... ";
	$id = trim($_POST['id']);
	$password = hash("sha512", trim($_POST['password']));
	$email = trim($_POST['email']);
	if (preg_match("/[A-Z]{3}/", $id)) {
		if (strlen($id) == 3) {
			$bd = new AccessBD();
			$resultat = $bd->insertUser($id, $password, $email);
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
		<p><b>email</b>: <input type="text" size="50" name="email" maxlength="128" required></p>
        <p><b>password</b>: <input type="text" size="50" name="password" maxlength="32" required></p>
        <p><input type="submit"></p>
      </form>
      <hr/>
		
		<p><?php echo "log: ".$debug; ?></p>
    </body>
</html>