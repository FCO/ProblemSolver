# Constrainer

```perl6
use Constrainer;

my $problem = Constrainer.new;

$problem.add-variable: "a", ^100;
$problem.add-variable: "b", ^100;

$problem.add-constraint: -> :$a!, :$b! {$a * 3 == $b + 14};
$problem.add-constraint: -> :$a!, :$b! {$a * 2 == $b};

say $problem.solve						# ((a => 14 b => 28))
```

```perl6
use Constrainer;
my $problem = Constrainer.new;

$problem.add-variable: "S", 1 ..^ 10;
$problem.add-variable: "E", ^10;
$problem.add-variable: "N", ^10;
$problem.add-variable: "D", ^10;
$problem.add-variable: "M", 1 ..^ 10;
$problem.add-variable: "O", ^10;
$problem.add-variable: "R", ^10;
$problem.add-variable: "Y", ^10;


#$problem.add-constraint: -> *%all {note "ALL {%all.values}"; [!=] %all.values};
$problem.constraint-vars: &infix:<!=>, <S E N D M O R Y>;
$problem.add-constraint: -> :$S!, :$E!, :$N!, :$D!, :$M!, :$O!, :$R!, :$Y! {
	note "$S$E$N$D + $M$O$R$E == $M$O$N$E$Y";

					1000*$S + 100*$E + 10*$N + $D
	+				1000*$M + 100*$O + 10*$R + $E
	==	10000*$M +	1000*$O + 100*$N + 10*$E + $Y
};


say $problem.solve
```
