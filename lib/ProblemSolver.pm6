unit class ProblemSolver;

has         %.variables;
has			%.constants;
has Bag     $.vars				.= new;
has 	    %.constraints{Set};
has 	    %.heuristics{Set};
has			&.print-found is rw;
has	Set		%.unordered;

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

method add-heuristic(Set() \consts where {%!variables{.keys.all}:exists}, &heuristic) {
	%!heuristics{consts}.push: &heuristic;
}

proto method remove-possibility($name, $value) {
	#note "remove-possibility($name, $value)";
	{*}
}

multi method remove-possibility(Str \name where {%!variables{name}:exists}, Set() \value) {
	for value.keys -> \v {
		nextwith(name, v)
	}
}

multi method remove-possibility(Set \name where {%!variables{.keys.all}:exists}, Set() \value) {
	for name.keys -> \n {
		nextwith(n, value)
	}
}

multi method remove-possibility(Str $name where {%!variables{$name}:exists}, \value) {
    %!variables{$name} = %!variables{$name} ∖ bag(value xx %!variables{$name}{value});
    die "No options" if %!variables{$name}.elems == 0;
    if %!variables{$name}.elems == 1 {
		%!variables = %!variables.pairs.grep: *.key !~~ $name;
		%!constants = |%!constants, $name => value
    }
}

method variable-bag {
    %!variables.keys
        .map(-> Str \var {
			my Int $in-constraints = %!constraints.pairs.grep(var ∈ *.key).map(*.value.elems).sum;
			my Int $in-heuristics  = %!heuristics.pairs.grep(var ∈ *.key).map(*.value.elems).sum;
            slip var xx ($!vars{var} * ($in-constraints + 1) * ($in-heuristics + 1))
        })
        .Bag
}

method get-constraints {
	|%!constraints.pairs.grep(*.key ⊆ %!constants.keys.Set).map: |*.value
}

method classify-heuristics {
	%!heuristics.pairs.classify: {%!constants{one(.key)}:!exists ?? .key !! Empty}, :as{.value}
}

method unique-value-vars(Set() \vars) {
	for vars.keys.combinations: 2 -> @vars {
		#say @vars;
		$.add-constraint(@vars, -> %vars { %vars{@vars[0]} !~~ %vars{@vars[1]} });
		$.add-heuristic( @vars, -> %vars { %vars{@vars[0]} !~~ %vars{@vars[1]} })
	}
}

method constraint-vars(Set() \vars, &constraint) {
	for vars.keys.combinations: 2 -> @vars {
		$.add-constraint(@vars, -> %vars { constraint |%vars{|@vars} });
		$.add-heuristic( @vars, -> %vars { constraint |%vars{|@vars} })
	}
}

method unordered-vars(Set() \vars) {
	for vars.keys -> Str $key {
		%!unordered{$key} = vars ∖ set($key);
	}
}

method run-heuristcs {
	# TODO: implement heuristics
	my %not-used{Set};
	for |%!heuristics.kv -> %sig, @heu {
		my \c = %sig.keys.classify: {%!constants{$_}:exists ?? "const" !! "var"}
		if c<var>.elems == 1 {
			my %consts = %!constants{|c<const>}:kv;
			my $var-name = c<var>.head;
			my &gfunc = -> $value {
				my %vars = |%consts, $var-name => $value;
				![&&] do for @heu { .(%vars) }
			}
			my %to-remove := set %!variables{$var-name}.keys.grep: &gfunc;
			$.remove-possibility($var-name, %to-remove)
		} else {
			%not-used{%sig} = @heu
		}
	}
	%not-used
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

sub test-unordered(%un, %test, $var, $value) {
	%un{$var}:exists and %test{%un{$var}.any}:exists and %test{%un{$var}.any}{$value}
}

method run-tests {
	my Set %tested = %!constants.kv.map: -> $key, $value {$key => set($value)};
	for $.get-constraints -> &constraint {
		return %tested unless constraint(%!constants)
	}
	.(%!constants) with &!print-found;
	if %.variable-bag.elems {
		my Str $var = $.next-variable;
		my %heuristics := $.run-heuristcs;
		for |%!variables{$var}.pairs.sort(-*.value).map: *.key -> $value {
			if test-unordered %!unordered, %tested, $var, $value {
				next
			}
			my %constants = |%!constants, $var => $value;
			my %variables = |%!variables.pairs.grep: *.key !~~ $var;
			my $clone = self.clone: :%variables, :%constants, :%heuristics, :vars($!vars ∖ bag($var xx $!vars{$var}));
			my %returned = $clone.run-tests;
			%tested = merge-used %tested, %returned;

			#note %tested;
			$.remove-possibility($_, %tested{|%!unordered{$_}}) for %!unordered.grep: {%tested{$_}:exists}
		}
	} else {
		take %!constants;
	}
	%tested
}
