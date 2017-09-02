use ProblemSolver;
my ProblemSolver $problem .= new;

$problem.create-variable: <a b>, ^100;

$problem.add-constraint: <a b>, -> %vars {%vars<a> * 3 == %vars<b> + 14};
$problem.add-constraint: <a b>, -> %vars {%vars<a> * 2 == %vars<b>};

#$problem.print-found = &say;
say $problem.solve.head
