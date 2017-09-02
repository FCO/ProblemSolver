unit class ProblemSolver;

has         %.variables;
has Bag     $.vars				.= new;
has 	    %.constraints{Set};
has 	    %.heuristics{Set};
has         %.found;
has			&.print-found is rw;

multi method create-variable(Str $name where { not %!variables{$_}:exists }, Bag() \values) {
	$!vars = |$!vars ⊎ Pair.new: $name, 1;
	%!variables = |%!variables, $name => values;
}

multi method create-variable(Bag() $names where { %!variables{$_.none}:exists }, Bag() \values) {
	$!vars = $!vars ⊎ $names;
	%!variables = |%!variables, |do for $names.keys -> $name { $name => values }
}

method add-constraint(Set() \vars where {%!variables{.keys.all}:exists}, &constraint) {
	%!constraints{vars}.push: &constraint
}

method add-heuristic(
	Set() \consts where {%!variables{.keys.all}:exists},
	Set() $to-rem where {%!variables{.keys.all}:exists},
	&heuristic
) {
	%!heuristics{consts}.push: {code => &heuristic, :$to-rem}
}

role Found {}
multi method remove-possibility(Str \name where {%!variables{name}:exists}, Set \value) {
	for value.keys -> \v {
		$.remove-possibility(name, v)
	}
}

multi method remove-possibility(Str \name where {%!variables{name}:exists}, \value) {
    %!variables{name} = %!variables{name} ∖ bag(value xx %!variables{name}{value});
    die "No options" if %!variables{name}.elems == 0;
    if %!variables{name}.elems == 1 {
        %!variables{name} = %!variables{name}.keys.head but Found;
    }
}

method constants {
	%!variables.pairs.grep({ .value ~~ Found }).Map
}

method variable-bag {
    %!variables.keys
        .grep(-> Str \key {
            %!variables{key} !~~ Found
        })
        .map(-> Str \var {
			my Int $in-constraints = %!constraints.pairs.grep(var ∈ *.key).map(*.value.elems).sum;
			my Int $in-heuristics  = %!heuristics.pairs.grep(var ∈ *.key).map(*.value.elems).sum;
            slip var xx ($!vars{var} * ($in-constraints + 1) * ($in-heuristics + 1))
        })
        .Bag
}

method get-constraints {
	|%!constraints.pairs.grep(*.key ⊆ $.constants.keys.Set).map: |*.value
}

method run-heuristcs {
	# TODO: implement heuristics
	for |%!heuristics.pairs.grep(*.key ⊆ $.constants.keys.Set).kv -> %from, (:&code, :%to-rem) {
		code(%from.keys)
	}
}

method next-variable {
    $.variable-bag.pairs.max({.value}).key
}

method solve {
    lazy gather $.run-tests;
}

sub merge-used(%a1, %a2) {
	(|%a1.keys, |%a2.keys).unique.map(-> Str $key {
		$key => (%a1{$key} // {}) ∪ (%a2{$key} // {})
	}).Map
}

method run-tests {
	my Set %tested = $.constants.kv.map: -> $key, $value {$key => set($value)};
	my %consts = $.constants;
	for $.get-constraints -> &constraint {
		return %tested unless constraint(%consts)
	}
	$_.(%consts) with &!print-found;
	if %.variable-bag.elems {
		my Str $var = $.next-variable;
		$.run-heuristcs;
		for |%!variables{$var}.pairs.sort(-*.value).map: *.key -> $value {
			my %variables = |%!variables, $var => $value but Found;
			my $clone = self.clone: :variables(%variables), :vars($!vars ∖ bag($var xx $!vars{$var}));
			my %returned = $clone.run-tests;
			%tested = merge-used %tested, %returned
			# TODO: remove the unordered var values
		}
	} else {
		take %consts;
	}
	%tested
}
