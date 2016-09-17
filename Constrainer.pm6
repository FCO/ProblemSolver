class Constrainer {
	has Callable	@!constraints handles add-constraint => 'push';
	has				%!variables;

	method add-variable(Str $name, @set) {
		%!variables.push: $name => @set
	}

	method constraint-vars(&red, @vars) {
		my $pars = &red.signature.params.elems;
		my @comb = @vars.combinations($pars);
		for @comb -> @pars {
			my $sig = @pars.map({":\${$_}!"}).join(", ");
			my $cal = @pars.map({"\${$_}"}).join(", ");
			use MONKEY-SEE-NO-EVAL;
			my &func = EVAL "-> $sig, | \{ red($cal)\}";
			no MONKEY-SEE-NO-EVAL;
			$.add-constraint(&func)
		}
	}

	method solve {
		self!solve-all([], %!variables)
	}

	method !get-constraints-for-vars(%vars) {
		@!constraints.grep: -> &func { %vars ~~ &func.signature }
	}

	method !solve-all(@did is copy,  %todo) {
		if %todo.keys (-) @did == 0 {
			return {%todo} if self!run-constraints(%todo);
			return
		}
		my @resp;
		@did.push: my $key = (%todo.keys (-) @did).first.key;
		for @( %todo{$key} ) -> $val {
			my %new = %todo;
			%new{$key} = $val;
			next unless self!run-constraints(%(@did Z=> %new{@did}));
			@resp.push: self!solve-all(@did, %new)
		}
		|@resp
	}

	method !run-constraints(%values) {
		my @cons = self!get-constraints-for-vars(%values);
		for @cons -> &func {
			return False if not func(|%values)
		}
		True
	}
}
