<?php
    session_start();
	$_SESSION['tab'] = "howWeDoIt";
    //refresh the page to the index
	header("Location: index.php");
?>
