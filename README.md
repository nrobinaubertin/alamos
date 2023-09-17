# Los Alamos Chess

## Goal
I want to have a benchmark test to compare performance of a simple algorithm in multiple programming languages.  
Code should be kept simple and idiomatic.  
So that the benchmark is neither too complex nor too simple, I've chosen to create a simple AI that plays [Los Alamos Chess](https://www.chessvariants.com/small.dir/losalamos.html).

## Rules
The AI should take as input a string of 36 characters representing the occupancy of each square and a string of 1 character reprensenting whose turn it is to play.  

For example, here is the command to run the python version with an example position:
```
./alamos.py r.qknr..p..pnp.pp....P..P.PKPPRNQ.NR b
```

It should use the negamax algorithm with a simple material evaluation and execute it at depth 6.  
The output should be the state of the board and the turn to play so that it can "feed itself" to selfplay.

The starting input is "rnqknrpppppp............PPPPPPRNQKNR w".

Here is the expected output after 40 turns of selfplay:
```
rnqknrpppppp......P......PPPPPRNQKNR b
rnqknrpp.ppp..p...P......PPPPPRNQKNR w
rnqknrpp.ppp..p...PP......PPPPRNQKNR b
rnqknrpp.ppp......Pp......PPPPRNQKNR w
rnqknrpp.ppp......PP.......PPPRNQKNR b
rn.knrpp.ppp......PP.......PPPRNqKNR w
rn.knrpp.ppp......PP.......PPPRNK.NR b
rn.k.rpp.ppp...n..PP.......PPPRNK.NR w
rn.k.rpp.ppp...n..PP.....K.PPPRN..NR b
rn.k.r.p.pppp..n..PP.....K.PPPRN..NR w
rn.k.r.p.pppP..n..P......K.PPPRN..NR b
r..k.r.p.pppn..n..P......K.PPPRN..NR w
r..k.r.p.pppn..n..P.....K..PPPRN..NR b
.r.k.r.p.pppn..n..P.....K..PPPRN..NR w
.r.k.r.p.pppn..n..P...P.K..P.PRN..NR b
.r.k.r.p.pppn.....P...P.K..PnPRN..NR w
.r.k.r.p.pppn.....P..NP.K..PnPRN...R b
.r.k.r.p..ppn..p..P..NP.K..PnPRN...R w
.r.k.r.p..ppn..p..P...P.K..PnPRNN..R b
.r.k.r....ppnp.p..P...P.K..PnPRNN..R w
.r.k.r....ppnP.p......P.K..PnPRNN..R b
.r.k.r....ppnP.p......P.K..P.PRNn..R w
.r.k.r....ppnP.p......P.K..P.PRNR... b
..rk.r....ppnP.p......P.K..P.PRNR... w
..rk.r....ppnP.p..N...P.K..P.PR.R... b
...k.r....ppnP.p..N...P.K..P.PR.r... w
...k.r....ppnP.p..N...P.K..P.P..R... b
.....r...kppnP.p..N...P.K..P.P..R... w
.....r...kppnP.P..N.....K..P.P..R... b
.....r....ppnP.k..N.....K..P.P..R... w
.....r....ppnP.k..NK.......P.P..R... b
.n...r....pp.P.k..NK.......P.P..R... w
.n...r....pp.P.k..NK.......P.P....R. b
.n..r.....pp.P.k..NK.......P.P....R. w
.n..r.....pp.P.k..NK..R....P.P...... b
.n...r....pp.P.k..NK..R....P.P...... w
.n...r....pp.P.k...K..R...NP.P...... b
.n...r...kpp.P.....K..R...NP.P...... w
.n...r...kpp.P.....K.R....NP.P...... b
.n...r....pp.P..k..K.R....NP.P...... w
.n...r....pp.P..k..K..R...NP.P...... b
```

## Results

On my laptop, I get the following results:  

| Language | Duration | Peak memory usage |
|----------|----------|-------------------|
| Python   | 70.63 s  | 8448 kb           |
| PHP      | 30.47 s  | 13824 kb          |
| Go       | 5.01 s   | 9596 kb           |
| C        | 2.55 s   | 1280 kb           |
| Rust     | 1.73 s   | 1536 kb           |

Of course, this will vary for each machine, so test on your own!
