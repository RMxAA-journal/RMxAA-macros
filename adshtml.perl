









package main;

$dum = &do_cmd_makeatletter();

sub do_cmd_RMAA {
    local($_) = @_;
    "RMxAA" . $_;
}

sub do_cmd_RMAASC {
    local($_) = @_;
    "RMxAASC" . $_;
}

sub do_cmd_etal {
    local($_) = @_;
    "et al\." . $_;
}

sub do_cmd_ibidrule {
    local($_) = @_;
    "<img src=\"foo\" alt=\"\ibidrule\">" . $_;
}

sub do_cmd_bibitem {
    local($_) = @_;
    local($key);
    local($opt, $dummy)=&get_next_optional_argument;
    $key = &missing_braces unless
        ((s/$next_pair_pr_rx/$key = $2; ''/eo)
        ||(s/$next_pair_rx/$key = $2; ''/eo));
    "<p>" . $_;
}

&ignore_commands (<<_RAW_ARG_CMDS_);
lowercase
adjustfinalcols
textsuperscript # {}
newline # []
thinmuskip
mskip
smallskip
medskip
bigskip
hspace # {}
hspacestar # {}
vspace # {}
vspacestar # {}
mathrm
_at_mathrm
spacefactor
discretionary
unhbox
voidb_at_x
penalty
_at_M
_at_m
null
IeC
_RAW_ARG_CMDS_

&process_commands_in_tex (<<_RAW_ARG_CMDS_);
sun
earth
lesssim
gtrsim
sq
argdeg
arcmin
arcsec
fd
fh
fm
fs
fdg
farcm
farcs
fp
micron
la
ga
case # {} # {}
slantfrac # {} # {}
onehalf
onethird
twothirds
onequarter
threequarters
ubvr
ub
bv
vr
ur
aj
araa
apj
apjl
apjs
ao
apss
aap
aapr
aaps
azh
baas
jrasc
memras
mnras
pra
prb
prc
prd
pre
prl
pasp
pasj
qjras
skytel
solphys
sovast
ssr
zap
nat
iaucirc
aplett
apspr
bain
fcp
gca
grl
jcp
jgr
jqsrt
memsai
nphysa
physrep
physscr
planss
procspie
_RAW_ARG_CMDS_

1;                              # This must be the last line




