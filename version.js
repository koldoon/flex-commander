var fs = require( "fs" );
var file = "./application.xml";

var VERSION_RXP = /<versionNumber>(\d+).(\d+).(\d+)<\/versionNumber>/m;
var data = fs.readFileSync( file, "utf8" );
var digits = VERSION_RXP.exec( data );
var newVersion = digits[ 1 ] + "." + digits[ 2 ] + "." + (Number( digits[ 3 ] ) + 1 );

data = data.replace( VERSION_RXP, "<versionNumber>" + newVersion + "</versionNumber>" );
fs.writeFileSync( file, data, "utf8" );

console.log( "NEW VERSION IS: " + newVersion );