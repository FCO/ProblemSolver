unit role Domain[@set] does Associative;

has Set		$.pos handles <AT-KEY EXISTS-KEY DELETE-KEY keys> = set @set;
has Int		$.elems = +@set;

method find-and-remove(&should-remove) {
	my %pos := set $.keys.grep: &should-remove;
	self.new: :%pos, :elems(%pos.elems);
}

method remove($val) {
	my %pos := $!pos (-) $val;
	self.new: :%pos, :elems(%pos.elems);
}
