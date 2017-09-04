use lib "lib";
use ProblemSolver;

class Point {
	has Int $.x;
	has Int $.y;

	method WHICH {
		"{self.^name}(:x($!x), :y($!y))"
	}
	method gist {$.WHICH}
	method Bool {$!x and $!y}
}

sub MAIN(Int $n = 4) {
	my ProblemSolver $problem .= new: :stop-on-first-solution;

	sub print-board(%values) {
		my @board;
		for %values.kv -> $key, (:x($row), :y($col)) {
			@board[$row; $col] = $key;
		}
		for ^$n -> $row {
			for ^$n -> $col {
				if @board[$row; $col]:exists {
					print "♛ "
				} else {
					print "☐ "
				}
			}
			print "\n"
		}
		print "\n"
	}

	$problem.print-found = -> %values {
		print "\e[0;0H\e[0J";
		print-board(%values);
		say +%values
	}

	my @board = (^$n X ^$n).map(-> ($x, $y) {Point.new: :$x, :$y});
	my @vars = (1 .. $n).map: {"Q$_"};

	$problem.create-variable: @vars, @board;

	#$problem.no-order-vars: @vars;
	$problem.unique-value-vars: @vars;

	$problem.constraint-vars: @vars, -> $q1, $q2 {
			$q1.x 			!= $q2.x
		&&	$q1.y			!= $q2.y
		&&	$q1.x - $q1.y	!= $q2.x - $q2.y
		&&	$q1.x + $q1.y	!= $q2.x + $q2.y
	};

	$problem.unordered-vars: @vars;

	my @solutions = eager $problem.solve;
	say "\n", "=" x 30, " Answers ", "=" x 30, "\n";
	for @solutions -> %ans {
		print-board(%ans)
	}

	#print-board($problem.solve.head)
}
