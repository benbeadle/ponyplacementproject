<?php
    session_start();
	$_SESSION['tab'] = "evaluate";
    $_SESSION['ponyUser'] == "Twilight Sparkle";
    //refresh the page to the index
    header("Location: index.php");
?>