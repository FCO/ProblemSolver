unit class ProblemSolver;

has         %.variables;
has Bag     $.vars				.= new;
has 	    %.constraints{Set};
has 	    %.heuristics{Str};
has         %.found;
has Bool    $!complete          = False;

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

role Found {}
multi method remove-possibility(Str \name where {%!variables{name}:exists}, \value) {
    %!variables{name} = %!variables{name} (-) bag(value xx %!variables{name}{value});
    die "No options" if %!variables{name}.elems == 0;
    if %!variables{name}.elems == 1 {
        %!variables{name} = %!variables{name}.keys.head but Found;
    }
}

method variable-bag {
    %!variables.keys
        .grep(-> Str \key {
            %!variables{key} !~~ Found
        })
        .map(-> Str \var {
            slip var xx (($!vars{var} * %!constraints.pairs.grep(var ∈ *.key).map(*.value.elems).sum) || 1)
        })
        .Bag
}

method variable-order {
    |$.variable-bag.pairs.sort({-.value}).map: {.key}
}

method solve {
    lazy gather $.run-tests;
}

method run-tests {
    $!complete = %!variables.values.all ~~ Found;
    # TODO: Run constraints
    take %!variables if $!complete;
    # TODO: Run heuristics
    for $.variable-order -> $var {
        for |%!variables{$var}.pairs.sort(-*.value).map: *.key -> $value {
            my %variables = |%!variables, $var => $value but Found;
            my $clone = self.clone: :variables(%variables), :vars($!vars (-) bag($var xx $!vars{$var}));
            $clone.run-tests
        }
    }
}
