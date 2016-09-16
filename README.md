# Constrainer

```perl6
use Constrainer;

my $problem = Constrainer.new;

$problem.add-variable: "a", ^100;
$problem.add-variable: "b", ^100;

$problem.add-constraint: -> :$a, :$b {$a * 3 == $b + 14};
$problem.add-constraint: -> :$a, :$b {$a * 2 == $b};

say $problem.solve
```
