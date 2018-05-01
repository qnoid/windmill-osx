BEGIN { 
	ORS=" "; print " [ " 
} 

/Build settings for action build and target/ { 
	counter++
}

$1 == "IPHONEOS_DEPLOYMENT_TARGET" {
	if (counter != 1) print ","
	print "{\"deployment\":{\"target\":"$3"}," 
}

$1 =="PRODUCT_NAME" { 
	print "\"product\":{\"name\":\""substr($0,index($0,$3))"\"" 
}

$1 =="PRODUCT_TYPE" { 
	print ", \"type\":\""substr($0,index($0,$3))"\"}," 
}

$1 =="PROJECT_NAME" {
    print "\"project\":{\"name\":\""substr($0,index($0,$3))"\"},"
}

$1 =="TARGETNAME" { 
	print "\"target\":{\"name\":\""substr($0,index($0,$3))"\"}}" 
}


END {
	print " ] "
}
