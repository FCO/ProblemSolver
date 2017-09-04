use ProblemSolver;
my ProblemSolver $problem .= new;

$problem.create-variable: <a b>, ^100;

$problem.add-constraint: <a b>, -> $_ {.<a> * 3 == .<b> + 14};
$problem.add-constraint: <a b>, -> $_ {.<a> * 2 == .<b>};
$problem.add-heuristic:  <a b>, -> $_ {.<a> < .<b>}

#$problem.print-found = &say;
say $problem.solve.head
