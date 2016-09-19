use lib ".";
use Problem;

sub MAIN(Int $n = 4) {
	my Problem $problem .= new: :stop-on-first-solution;

	sub print-board(%values) {
		my @board;
		for %values.kv -> $key, ($row, $col) {
			@board[$row; $col] = $key;
		}
		for ^$n -> $row {
			for ^$n -> $col {
				if @board[$row; $col]:exists {
					print "● "
				} else {
					print "◦ "
				}
			}
			print "\n"
		}
		print "\n"
	}

	$problem.print-found = -> %values {
		print "\e[0;0H\e[0J";
		print-board(%values);
	}

	my @board = ^$n X ^$n;
	my @vars = (1 .. $n).map: {"Q$_"};

	for @vars -> $var {
		$problem.add-variable: $var, @board;
	}

	$problem.constraint-vars: -> $q1, $q2 { $q1[0] != $q2[0] && $q1[1] != $q2[1] }, @vars;

	$problem.constraint-vars: -> $q1, $q2 {
			$q1[0] 			!= $q2[0]
		&&	$q1[1]			!= $q2[1]
		&&	$q1[0] - $q1[1]	!= $q2[0] - $q2[1]
		&&	$q1[0] + $q1[1]	!= $q2[0] + $q2[1]
	}, @vars;

	my @response = $problem.solve;
	say "\n", "=" x 30, " Answers ", "=" x 30, "\n";

	for @response -> %ans {
		print-board(%ans)
	}
}
