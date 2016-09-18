unit class Problem;
use State;

has Callable	@!constraints	handles add-constraint	=> 'push';
has Callable	%!heuristics	handles add-heuristic	=> 'push';
has	State		$!variables		handles <add-variable>	.= new;

method solve {
	self!solve-all($!variables)
}

method !solve-all($todo) {
	if $todo.found-everything {
		my %tmp = $todo.Hash;
		return %tmp if self!run-constraints(%tmp);
		return
	}
	my @resp;
	my $key = $todo.next-var;
	for $todo.iterate-over($key) -> $new {
		next unless self!run-constraints($new.found-hash);
		self!remove-values($new, :variable($key), :value($new.get($key))) if %!heuristics{$key}:exists;
		@resp.push: self!solve-all($new);
	}
	|@resp
}

method !remove-values($todo, Str :$variable, :$value) {
	if %!heuristics{$variable}:exists {
		for @( %!heuristics{$variable} ) -> &func {
			func($todo, $value)
		}
	}
}

method !run-constraints(%values) {
	my @cons = self!get-constraints-for-vars(%values);
	for @cons -> &func {
		return False if not func(|%values)
	}
	True
}

method !get-constraints-for-vars(%vars) {
	@!constraints.grep: -> &func { %vars ~~ &func.signature }
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
	for @vars -> $var {
		$.add-heuristic($var => -> $todo, $value {
			for @vars.grep(* !eq $var) (&) $todo.not-found-vars -> $var {
				$todo.find-and-remove-from: $var.key, &red.assuming: $value
			}
		})
	}
}

