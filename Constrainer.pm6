class Constrainer {
	has Callable	@!constraints handles add-constraint => 'push';
	has				%!variables;

	method add-variable(Str $name, @set) {
		%!variables.push: $name => @set
	}

	method solve {
		my @keys = %!variables.keys;
		do for [X] %!variables{@keys} -> (*@pars) {
			my %vars = @keys Z=> @pars;
			@keys Z=> @pars if all(@!constraints).(|%vars)
		}
	}
}
