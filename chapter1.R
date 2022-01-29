library(bnlearn)

# DAGs 
# no cyles are allowed
# arcs are interpreted as dependence rather than causal effects
# i.e. child vertex depends on parent vertex

DAG = empty.graph(nodes=c("A", "S", "E", "O", "R", "T"))
DAG = set.arc(DAG, from = "A", to="E")
DAG = set.arc(DAG, from = "S", to="E")
DAG = set.arc(DAG, from = "E", to="O")
DAG = set.arc(DAG, from = "E", to="R")
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
# the eq. is a submodel/nested model of the global distr.

# parentless variables are modelled as unidimensional prob. tables
A.prob=array(c(0.30, 0.50, 0.20), dim=3, dimnames=list(A=A.lv))
S.prob=array(c(0.60, 0.40), dim=2, dimnames=list(S=S.lv))

# two dim. prob. tables
# cols are levels of parent, distr. of variable is kept conditional on that level
O.prob=array(c(0.96, 0.04, 0.92, 0.08), dim=c(2,2), dimnames=list(O=O.lv, E=E.lv))
R.prob=array(c(0.25, 0.75, 0.20, 0.80), dim=c(2,2), dimnames=list(R=R.lv, E=E.lv))

# two parens, 3 dim. prob. tables
E.prob=array(c(0.48, 0.42, 0.10, 0.56, 0.36, 0.08, 0.58, 0.24, 0.18, 0.70, 0.21, 0.09), dim=c(2,3, 2), dimnames=list( E=E.lv, A=A.lv, S=S.lv))
