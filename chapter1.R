library(bnlearn)

# DAGs
# no cyles are allowed
# arcs are interpreted as dependence (direct dependence relationship) rather than causal effects
# i.e. child vertex depends on parent vertex
# paths: indirect relationship (indirect dependencies) - traversing the graph
# cycles such as A -> ... -> A are not allowed

DAG = empty.graph(nodes=c("A", "S", "E", "O", "R", "T"))

# AGE direct influence on Education
DAG = set.arc(DAG, from = "A", to="E")

# GENDER direct influence on Education
DAG = set.arc(DAG, from = "S", to="E")

# Education's influences:
DAG = set.arc(DAG, from = "E", to="O")
DAG = set.arc(DAG, from = "E", to="R")

# Residence and Occupation influence on Travel
DAG = set.arc(DAG, from = "R", to="T")
DAG = set.arc(DAG, from = "O", to="T")
plot(DAG)

# graph structure = product of conditional probabilities
modelstring(DAG)
nodes(DAG)
arcs(DAG)

DAG2 = empty.graph(nodes=c("A", "S", "E", "O", "R", "T"))
arc.set=matrix(c("A", "E", "S", "E", "E", "O", "E", "R", "R", "T", "O", "T"), 
            ncol=2, 
            byrow=TRUE, 
            dimnames=list(NULL, c("from", "to")))
arcs(DAG2)=arc.set
plot(DAG2)

# Global Distribution: the joint probability distribution of all the data (e.g. all possible pairs of values)
# normally this is broken down to local distributions - one for each variables
# assumtion is that if no arc is present, the variables are conditionally independent
# to specify the joint prob. distribution over these variables
# we add non-ordered states
A.lv=c("young", "adult", "old")
S.lv=c("M", "F")
E.lv=c("high", "uni")
O.lv=c("emp", "self")
R.lv=c("small", "big")
T.lv=c("car", "train", "other")

# the joint d. is called *global distribution* in this context
# the DAG information is used to break down the global distribution into local distributions
# variables not connected by an arc are conditionally independent
# factorization of the global distribution:
# Pr (ASEORT) = Pr(A)Pr(S)Pr(E | AS)Pr(O|E)Pr(R|E)Pr(T|RO)
# this eq. shows how the dependencies encoded in the DAG map into 
# the prob. space via the conditional dependencies
# factorization is well defined, as there are no cycles
# the set of all local d.s have fewer parameters than the glo. dist.
# the eq. is a submodel/nested model of the global distr.

# parentless variables are modelled as unidimensional prob. tables, i.e. has no parent
A.prob=array(c(0.30, 0.50, 0.20), dim=3, dimnames=list(A=A.lv))
S.prob=array(c(0.60, 0.40), dim=2, dimnames=list(S=S.lv))

# two dim. prob. tables
# cols are levels of parent, distr. of variable is kept conditional on that level
# ps of columns sum to 1
O.prob=array(c(0.96, 0.04, 0.92, 0.08), dim=c(2,2), dimnames=list(O=O.lv, E=E.lv))
R.prob=array(c(0.25, 0.75, 0.20, 0.80), dim=c(2,2), dimnames=list(R=R.lv, E=E.lv))

# two parens, 3 dim. prob. tables
E.prob=array(c(0.75, 0.25, 0.72, 0.28, 0.88, 0.12, 0.64, 0.36, 0.70, 0.30, 0.90, 0.10),
    dim=c(2,3,2), 
    dimnames=list( E=E.lv,A=A.lv, S=S.lv))

T.prob=array(c(0.48, 0.42, 0.10, 0.56, 0.36, 0.08, 0.58, 0.24, 0.18, 0.70, 0.21, 0.09),
    dim=c(3,2,2), 
    dimnames=list( T=T.lv, O=O.lv, R=R.lv))

# BNs involve this kind of dim. reduction: local distr. present fewer parameters than
# global and local distr. can be handled independently from the rest

DAG3=model2network("[A][S][E|A:S][O|E][R|E][T|O:R]")
cpt=list(A=A.prob, S=S.prob, T=T.prob, O=O.prob, R=R.prob, E=E.prob)
bn=custom.fit(DAG, cpt)
nparams(bn)

# Estimating the parameters

# a more typical case: learning local distributions from the data
survey=read.table("data/survey.txt", header=T, colClasses='factor')
# conditional probabilities in the local distributions are estimated from the
# empirical frequencies
# this yields the classic frequentist and  maximum likelihood estimates
bn.mle=bn.fit(DAG, data=survey, method='mle') # the structure is assumed to be known, and passed as DAG

# alternatively, the bayesian approach using the posterior distributions
bn.bayes=bn.fit(DAG, data=survey, method='bayes', iss=10) 
# iss = imaginary sample size (equivalent sample size) = how much weight is assigned to the prior distribution
# this weight is specified as the size of an imaginary sample supporting the prior distribution, normally 1 to 10
# more robust than MLE and has better predictive power
# higher ISS makes the posterior more flat / contrasted


n=nrow(survey)
mask= survey$O=='emp' & survey$E=='high'
idx=seq(1,n)[mask]
poe=nrow(survey[idx,])

mask= survey$E=='high'
idx=seq(1,n)[mask]
pe=nrow(survey[idx,])

p_OE = poe/n
p_E = pe/n
nO=nlevels(bn.bayes$O)
nE=nlevels(bn.bayes$E)
