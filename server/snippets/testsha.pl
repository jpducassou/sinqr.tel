
use Digest::SHA;
$digest = Digest::SHA->new();

$digest->reset();
print $digest->sha1_hex('FNC|Particia|TestOk.kmz|Posici�n C') . "\n";
$digest->reset();
print $digest->sha1_hex('FNC|Particia|TestOk.kmz|Posici�n C') . "\n";
$digest->reset();
print $digest->sha1_hex('FNC|Particia|TestOk.kmz|Posici�n C') . "\n";
$digest->reset();
print $digest->sha256_hex('FNC|Particia|TestOk.kmz|Posici�n C') . "\n";
$digest->reset();
print $digest->sha256_hex('FNC|Particia|TestOk.kmz|Posici�n C') . "\n";
$digest->reset();
print $digest->sha256_hex('FNC|Particia|TestOk.kmz|Posici�n C') . "\n";