unit role Domain[@set] does Associative;

has Set $.pos handles <AT-KEY EXISTS-KEY DELETE-KEY keys> = set @set;

method find-and-remove(&should-remove) {
	self.new: :pos(set self.keys.grep: -> $val {should-remove($val)} )
}
