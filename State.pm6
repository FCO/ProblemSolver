unit class State;
use Domain;

has 			%.vars;
has 			%.found		= Set.new;
has ::?CLASS	$.parent;

multi method add-variable(Str $name, $value) {
	%!vars{$name} = $value;
	%!found = %!found (|) $name
}

multi method add-variable(Str $name, @set) {
	%!vars{$name} = Domain[@set].new
}

method Hash {
	my @keys = %!vars.keys;
	%( @keys Z=> %!vars{@keys} )
}

method found-hash {
	my @keys = %!found.keys;
	%( @keys Z=> %!vars{@keys} )
}

method found-everything {
	%!found ~~ set %!vars.keys
}

method next-var {
	$.not-found-vars.first
}

method found-vars {
	%!found.keys
}

method not-found-vars {
	(%!vars.keys (-) %!found).keys
}

method get(Str $var where {%!found{$_}}) {
	%!vars{$var}
}

method iterate-over(Str $var where {not %!found{$_}}) {
	gather for %!vars{$var}.keys -> $val {
		my %tmp		= self.Hash;
		%tmp{$var}	= $val;
		take self.new: :vars(%tmp), :found(%!found (|) $var), :parent(self)
	}
}

method recursive-find-and-remove-from(Str $var where {not %!found{$_}}, &should-remove) {
	$!parent.recursive-find-and-remove-from($var, &should-remove) if $!parent;
	$.find-and-remove-from($var, &should-remove)
}

method find-and-remove-from(Str $var where {not %!found{$_}}, &should-remove) {
	%!vars{$var} .= find-and-remove(&should-remove);
}
