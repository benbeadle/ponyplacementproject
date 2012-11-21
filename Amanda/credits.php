<?php
    session_start();
	$_SESSION['tab'] = "credits";
    //refresh the page to the index
	header("Location: index.php");
?>