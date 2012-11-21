<?php
	session_start(); // start up your PHP session! 
	if(!isset($_SESSION['tab']))
		$_SESSION['tab'] = "evaluate";
	if(!isset($_SESSION['ponyUser']))
		$_SESSION['ponyUser'] = "Default Pony";
?>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" 
	"http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"> 

    <html xmlns = "http://www.w3.org/1999/xhtml" lang = "en" xml:lang = "en">
	<head>
		<meta http-equiv = "Content-Type" content = "text/html; charset = ISO-8859-1" />
		<META HTTP-EQUIV="CACHE-CONTROL" CONTENT="NO-CACHE">
		<META HTTP-EQUIV="PRAGMA" CONTENT="NO-CACHE">
		<title>Pony Placement Project</title>
		<link type = "text/css" rel = "stylesheet" href = "pony.css" media = "screen" />
	</head>
	<body>		
		<div id = "header">
            <img src="My_Little_Pony_Friendship_is_Magic_logo.png" alt="Klematis">
			<h1>The Pony Placement Project</h1>
			<h3>Where you discover your inner Pony.</h3>
		</div>
        <div id = "buttonBar">
            <ul>
                <li><a href="evaluate.php">Evaluate</a></li>
                <li><a href="howWeDoIt.php">How We Do It</a></li>
                <li><a href="credits.php">Credits</a></li>
                <li><a href="about.asp">GitHub Code</a></li>
            </ul>
        </div>
        <div id = "content">
            <?php
            if($_SESSION['tab'] == "evaluate" && $_SESSION['ponyUser'] == "Default Pony") {
            ?>
                <p> You are not a pony yet. </p>
            <?php
            }
            else if ($_SESSION['tab'] == "evaluate" && $_SESSION['ponyUser'] == "Twilight Sparkle") {
            ?> 
                <p> You are Twilight Sparkle. </p>
            <?php
            }
            else if ($_SESSION['tab'] == "evaluate" && $_SESSION['ponyUser'] == "Rainbow Dash") {
            ?> 
                <p> You are Rainbow Dash. </p>
            <?php
            }
            else if ($_SESSION['tab'] == "evaluate" && $_SESSION['ponyUser'] == "Rarity") {
            ?> 
                <p> You are Rarity. </p>
            <?php
            }
            else if ($_SESSION['tab'] == "evaluate" && $_SESSION['ponyUser'] == "Fluttershy") {
            ?> 
                <p> You are Fluttershy. </p>
            <?php
            }
            else if ($_SESSION['tab'] == "evaluate" && $_SESSION['ponyUser'] == "Applejack") {
            ?> 
                <p> You are Applejack. </p>
            <?php
            }
            else if ($_SESSION['tab'] == "evaluate" && $_SESSION['ponyUser'] == "Pinkie Pie") {
            ?> 
                <p> You are Pinkie Pie. </p>
            <?php
			}
            else if ($_SESSION['tab'] == "evaluate" && $_SESSION['ponyUser'] == "Spike") {
            ?> 
                <p> You are Spike. </p>
            <?php
            } 
            else if ($_SESSION['tab'] == "howWeDoIt") {
            ?>
                <p> This explains what we used to figure how what pony you are. </p>
            <?php
            }
            else if ($_SESSION['tab'] == "credits") {
            ?>
                <p> This site was developed by Amanda Cofsky and Ben Beadle.</p>
            <?php
            }
            ?>
        </div>
		<div id = "footer">
			<p>
				&copy; 2012, Pony Placement Project<br />
				All trademarks and registered trademarks appearing on this site are 
				the property of their respective owners. We do not discriminate on 
				bases of of race, color, creed, religion, sex, age, handicap, 
				marital status, or national origin. We do not take reponsibility 
				for any bad experiences do to taking advice posted on this site.
			</p>
		</div>
	</body>
</html>