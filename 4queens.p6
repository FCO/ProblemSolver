use lib ".";

use Problem;
my Problem $problem .= new: :stop-on-first-solution;

sub print-board(%values) {
	my @board;
	for %values.kv -> $key, ($row, $col) {
		@board[$row; $col] = $key;
	}
	for ^4 -> $row {
		for ^4 -> $col {
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

$problem.print-found = &print-board;

my @board = ^4 X ^4;

$problem.add-variable: "Q1", @board;
$problem.add-variable: "Q2", @board;
$problem.add-variable: "Q3", @board;
$problem.add-variable: "Q4", @board;


$problem.constraint-vars: -> $q1, $q2 { $q1[0] != $q2[0] && $q1[1] != $q2[1] }, <Q1 Q2 Q3 Q4>;

$problem.constraint-vars: -> $q1, $q2 {
		$q1[0] 			!= $q2[0]
	&&	$q1[1]			!= $q2[1]
	&&	$q1[0] - $q1[1]	!= $q2[0] - $q2[1]
	&&	$q1[0] + $q1[1]	!= $q2[0] + $q2[1]
}, <Q1 Q2 Q3 Q4>;

my @response = $problem.solve;
say "\n", "=" x 30, "Answers", "=" x 30, "\n";

for @response -> %ans {
	print-board(%ans)
}
