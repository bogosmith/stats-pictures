use strict;
use warnings;
use POSIX;
use constant PI => 4 *atan2(1,1);
use Math::Trig;


my $usage="<script_name> lat lon kms";

# the result is y modulo x
sub modulo_euclid {
  my ($y, $x) = @_;
  my $mod = $y - $x*floor($y/$x);
  if ($mod < 0 ) {$mod = $mod + $x}
  return ($mod);
}
# one minute is 1852 meters
my $great_arc_degree = 60*1852;
my $great_arc_radian = (180/PI)*$great_arc_degree;

sub km_to_rad {
  my ($km) = @_;
  return $km*1000/$great_arc_radian; 
}

sub rad_to_deg {
  my ($rad) = @_;
  return (180/PI)*$rad;  
}

sub deg_to_rad {
  my ($deg) = @_;
  return (PI/180)*$deg; 
}

sub get_vertical_north_from {
  my ($lat, $lon, $d)= @_;
  my $newlat = asin(sin($lat)*cos($d) + cos($lat)*sin($d));
  return ($newlat, $lon); 
}

sub get_horizontal_west_from {
  my ($lat, $lon, $d)= @_;
  #print $lat, " ", $lon, " ", $d;
  my $newlon = modulo_euclid($lon-asin(sin($d)/cos($lat))+ PI, 2*PI) - PI;
  #my $newlon = (($lon-asin(sin($d)/cos($lat))+ PI)%(2*PI)) - PI;
  return ($lat, $newlon); 
}
while(<>) {
  chomp;
  my @toks = split(/\s/);
  my $lat = $toks[0];
  my $lon = $toks[1];
  my $kmside = $toks[2];
  die "Point too close to the 180-th degree meridian.", $lat, " ", $lon  unless (180 - abs($lon)) > rad_to_deg(km_to_rad($kmside/2));
  #my ($lat, $lon, $kmside) = @ARGV;
  my ($northlat, $northlon) = get_vertical_north_from(deg_to_rad($lat), deg_to_rad($lon), km_to_rad($kmside/2));
  my ($southlat, $southlon) = get_vertical_north_from(deg_to_rad($lat), deg_to_rad($lon), -km_to_rad($kmside/2));
  my ($minlat, $minlon) = get_horizontal_west_from($southlat, $southlon, km_to_rad($kmside/2));
  my ($maxlat, $maxlon) = get_horizontal_west_from($northlat, $northlon, -km_to_rad($kmside/2));

  print rad_to_deg($minlon), " ", rad_to_deg($minlat), " ", rad_to_deg($maxlon), " ", rad_to_deg($maxlat), "\n";
  #print $_;
}
#print $newlat, " ", $newlon, "\n";
#print modulo_euclid(2*PI, 0.12+PI) - PI, "\n";
#print km_to_rad(13000);
#print rad_to_deg(3.14);



#if (not defined $lat or not defined $lon) { die $usage; }
#print "\n", $lat, " ", $lon," ", modulo_euclid($lat, $lon), "\n";
#modulo_euclid($lat, $lon);

