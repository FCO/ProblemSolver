use lib ".";

use Problem;
my Problem $problem .= new: :stop-on-first-solution;

my @colors = <green yellow blue white>;

my @states = <
	acre				alagoas
	amapa				amazonas
	bahia				ceara
	espirito-santo		goias
	maranhao			mato-grosso
	mato-grosso-do-sul	minas-gerais
	para				paraiba
	parana				pernambuco
	piaui				rio-de-janeiro
	rio-grande-do-norte	rio-grande-do-sul
	rondonia			roraima
	santa-catarina		sao-paulo
	sergipe				tocantins
>;

for @states -> $state {
	$problem.add-variable: $state, @colors;
}

$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <acre amazonas>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <amazonas roraima>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <amazonas rondonia>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <amazonas para>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <para amapa>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <para tocantins>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <para mato-grosso>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <para maranhao>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <maranhao tocantins>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <maranhao piaui>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <piaui ceara>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <piaui pernambuco>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <piaui bahia>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <ceara rio-grande-do-norte>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <ceara paraiba>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <ceara pernambuco>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <rio-grande-do-norte paraiba>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <pernambuco alagoas>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <alagoas sergipe>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <sergipe bahia>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <bahia minas-gerais>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <bahia espirito-santo>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <bahia tocantins>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <bahia goias>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <mato-grosso goias>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <mato-grosso tocantins>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <mato-grosso rondonia>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <mato-grosso mato-grosso-do-sul>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <mato-grosso-do-sul goias>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <mato-grosso-do-sul minas-gerais>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <mato-grosso-do-sul sao-paulo>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <mato-grosso-do-sul parana>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <sao-paulo minas-gerais>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <sao-paulo rio-de-janeiro>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <rio-de-janeiro espirito-santo>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <rio-de-janeiro minas-gerais>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <minas-gerais espirito-santo>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <parana santa-catarina>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <santa-catarina rio-grande-do-sul>;

my %res = $problem.solve.first;
my $size = %res.keys.map(*.chars).max;
for %res.kv -> $state, $color {
	printf "%{$size}s => %s\n", $state, $color;
}

