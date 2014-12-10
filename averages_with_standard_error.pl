#!/usr/bin/perl

my $index = undef;
if ($#ARGV >= 0) {
	$index = $ARGV[0] - 1;
}

my $old_index_val = undef;

my @values = ();
while(<STDIN>) {
	chomp;
	my @current_values = /([^,]+)/g;
	if (!defined($old_index_val)) {
		$old_index_val = $current_values[$index];
	}
	elsif (defined($index) && ($old_index_val != $current_values[$index]
			|| $old_index_val ne $current_values[$index])) {
		$old_index_val = $current_values[$index];

		for(my $i = 0; $i < @values; $i++) {
			if ($i == $index) {
				print ${$values[$i]}[0],",",${$values[$i]}[0],",";
			}
			else {
				my $mean = 0;
				my $error = 0;
				for my $v (@{$values[$i]}) {
					$mean+=$v;
				}
				my $value_ref = @$values;
				$mean /= $#{$values[$i]} + 1;
			
				for my $v (@{$values[$i]}) {
					$error += ($v - $mean)**2;
				}
				if ($#{$values[$i]} > 0) {
					$error /= $#{$values[$i]};
				}
				$error = sqrt($error);
				if ($#{$values[$i]} > 0) {
					$error /= sqrt($#{$values[$i]});
				}
				$error *= 1.96;
				print "$mean,$error";
				if ($i < $#values) {
					print ",";
				}
			}
		}
		print "\n";

		@values = ();
	}
	for(my $i = 0; $i < @current_values; $i++) {
		if (!defined($values[$i])) {
			$values[$i] = ();
		}
		push(@{$values[$i]}, $current_values[$i]);
	}
}
for(my $i = 0; $i < @values; $i++) {
	if ($i == $index) {
		print ${$values[$i]}[0],",",${$values[$i]}[0],",";
	}
	else {
		my $mean = 0;
		my $error = 0;
		for my $v (@{$values[$i]}) {
			$mean+=$v;
		}
		my $value_ref = @$values;
		$mean /= $#{$values[$i]} + 1;
	
		for my $v (@{$values[$i]}) {
			$error += ($v - $mean)**2;
		}
		if ($#{$values[$i]} > 0) {
			$error /= $#{$values[$i]};
		}
		$error = sqrt($error);
		if ($#{$values[$i]} > 0) {
			$error /= sqrt($#{$values[$i]});
		}
		$error *= 1.96;
		print "$mean,$error";
		if ($i < $#values) {
			print ",";
		}
	}
}
print "\n";
