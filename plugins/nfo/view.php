<?php
	require_once( '../../php/settings.php' );
	require_once( '../../php/rtorrent.php' );

	function getNFO() {
		if ($_GET['id']) {
			$hash = $_GET['id'];
                        $req = new rXMLRPCRequest( array(
                                new rXMLRPCCommand( "d.get_base_path", $hash ),
                                new rXMLRPCCommand( "d.get_name", $hash ) )
                        );
                        if($req->success()) {
				$dir = $req->val[0];

				if ($h = opendir($dir)) {
					while (false !== ($file = readdir($h))) {
						if (preg_match("/\.nfo$/", $file)) {
							return file_get_contents($dir."/".$file);
						}
					}
				}
			}
		} 
		return false;
	}

	echo htmlentities(getNFO());
?>
