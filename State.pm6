unit class State;
use Domain;

has %.vars;
has %.found = Set.new;

method add-variable(Str $name, @set) {
	%!vars{$name} = Domain[@set].new
}

method Hash {
	my %tmp;
	for %!vars.keys -> $key {
		%tmp{$key} = %!vars{$key};
		%tmp{$key} .= clone if $key (elem) %!found;
	}
	%tmp
}

method found-hash {
	my %tmp;
	for %!found.keys -> $key {
		%tmp{$key} = %!vars{$key}
	}
	%tmp
}

method found-everything {
	%!found ~~ set %!vars.keys
}

method next-var {
	$.not-found-vars.first
}

method not-found-vars {
	(%!vars.keys (-) %!found).keys
}

method get(Str $var where * ~~ any(%!found.keys)) {
	%!vars{$var}
}

method iterate-over(Str $var where * !~~ any(%!found.keys)) {
	gather for %!vars{$var}.keys -> $val {
		my %tmp		= self.Hash;
		%tmp{$var}	= $val;
		my @found	= %!found.keys;
		@found.push: $var;
		take self.new: :vars(%tmp), :found(set @found)
	}
}

method find-and-remove-from(Str $var where * !~~ any(%!found.keys), &should-remove) {
	%!vars{$var} .= find-and-remove(&should-remove);
}
