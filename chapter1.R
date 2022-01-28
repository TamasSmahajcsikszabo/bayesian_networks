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
