
use Digest::SHA;
$digest = Digest::SHA->new();

$digest->reset();
print $digest->sha1_hex('FNC|Particia|TestOk.kmz|Posición C') . "\n";
$digest->reset();
print $digest->sha1_hex('FNC|Particia|TestOk.kmz|Posición C') . "\n";
$digest->reset();
print $digest->sha1_hex('FNC|Particia|TestOk.kmz|Posición C') . "\n";
$digest->reset();
print $digest->sha256_hex('FNC|Particia|TestOk.kmz|Posición C') . "\n";
$digest->reset();
print $digest->sha256_hex('FNC|Particia|TestOk.kmz|Posición C') . "\n";
$digest->reset();
print $digest->sha256_hex('FNC|Particia|TestOk.kmz|Posición C') . "\n";