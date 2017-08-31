unit class ProblemSolver;

has     %.variables;
has Bag $.vars				.= new;
has 	%.constraints{Set};
has 	%.heuristics{Str};
has     %.found;

multi method create-variable(Str $name where { not %!variables{$_}:exists }, Bag() \values) {
	$!vars = |$!vars (+) Pair.new: $name, 1;
	%!variables = |%!variables, $name => values;
}

multi method create-variable(Bag $names where { %!variables{$_.none}:exists }, Bag() \values) {
	$!vars = $!vars (+) $names;
	%!variables = |%!variables, |do for $names.keys -> $name { $name => values }
}

method add-constraint(Set() \vars where {%!variables{vars.keys.all}:exists}, &constraint) {
	%!constraints{vars}.push: &constraint
}

method add-heuristic(Set() \vars where {%!variables{vars.keys.all}:exists}, &heuristic) {
	%!heuristics{$_}.push: &heuristic for vars.keys
}

multi method remove-possibility(Str \name where {%!variables{name}:exists}, \value) {
    %!variables{name} = %!variables{name} (-) bag(value xx %!variables{name}{value});
    fail if %!variables{name}.elems == 0;
    %!variables{name} = %!variables{name}.keys[0] if %!variables{name}.elems == 1;
}

method variable-bag {
    %!variables.keys.map(-> Str \var {
        slip var xx (($!vars{var} * %!constraints.pairs.grep(var ∈ *.key).map(*.value.elems).sum) || 1)
    }).Bag
}

method variable-order {
    |$.variable-bag.pairs.sort({-.value}).map: {.key}
}

method solve {
    # TODO: Run constraints
    # TODO: Run heuristics
    for $.variable-order -> $var {
        for |%!variables{$var}.pairs.sort(-*.value).map: *.key -> $value {
            my %variables = |%!variables, $var => $value;
            my $clone = self.clone: :variables(%variables), :vars($!vars (-) bag($var xx $!vars{$var}));
            note $clone
        }
    }
}
