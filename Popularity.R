#' ---
#' title: "Popularity"
#' subtitle: "PLSC 508 Political Networks"
#' author: "Ishita Gopal"
#' date: "2/11/2020"
#' output: html_document
#' ---
#' 
## ----setup, include=FALSE--------------------------------------------------------------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)

#' 
## ---- warning=F, results=F, message=F--------------------------------------------------------------------------------------------
library(igraph)
library(dplyr)

#' 
#' There are various functions to generate networks with specific properties using the igraph library. We can use these to study and play the network game and explore properties of the generated networks. 
#' 
#' Here, I will first generate a random graph accroding to the Erdos-Renyi model. Using this model, we take two nodes and randomly place a link between them with a constant probability. It can be thought of as taking two nodes, rolling a dice and placing a node, say, if we roll a 6. The probability here is 1/6. We can set higher probabilities, and the higher a probability we set, the more connected the graph will become. This is something we also saw in the simulation example in last week's lecture. It is a simple system which is governed only the probability parameter.
#' 
#' Having an idea of what a network without any specific rules looks like allows us to more easily assess the peculiar networks we encounter. If the properties of these networks differ, we can analyze the rules which differ between the two.  
#' 
#' The erdos.renyi.game function in the igraph library allows us to generate a random graph and in this example, I have asked it to generate a graph with 50 vertices with a probability of drawing an edge set to .1. The type argument is just specifying that the graph has 'n' (=50) vertices and for each edge the probability that it is present in the graph is ‘p'(.1).We can also specify if we want to the graph to be directed or not. And if there should be loops. Here, I am generating an undirected grpah with no loops. 
## --------------------------------------------------------------------------------------------------------------------------------
# ?? random.graph.game
set.seed(1234)
# No. of nodes/vertices
size = 50 

# create a random network 
g = erdos.renyi.game(size, p.or.m = .1, type = "gnp")

# plot the network 
plot(g, vertex.color="light blue", 
     vertex.size = 5,        
     vertex.label.dist = 1)

# We can also change the layout of the graph
#plot the nodes in a circle
plot(g, vertex.color="light blue", 
     vertex.size = 5, 
     vertex.label.dist = 1, 
     layout=layout.circle)


#' 
#' For illustration, I used only 50 nodes in the above example. But it will be difficult to visually interpret the degree distribution with just 50 data point. So, below I generate a graph with 1000 nodes and the same probability of creating an edge (0.1). 
#' 
#' As can be seen, the degree distribution seems to folllow a symmetric distribution. There are some nodes which have a very low degree and some which have a very high degree at the extremes of the plot, but overall, there seems to be a well defined average degree of ~ 100. 
#' 
#' There is low clustering in random networks, meaning that it rarely contains highly connected nodes. So, they are not good candidates for studying highly connected designs. Networks in the real world are more constrained than random networks which gives them their distinct pattern. 
## --------------------------------------------------------------------------------------------------------------------------------
set.seed(1234)
# set the size of the nodes to 
sizex = 1000

#generate random graph with p = .1
gx = erdos.renyi.game(sizex, p.or.m = 0.1, type = "gnp")

d1 <- igraph::degree(gx)
h1 <- hist(d1, main="random graph", col="Gray")


#' 
#' Now, to create a network studied in class today, we want our graph to contain many nodes which have a low degree of connectivity and very few nodes which have a very high degree of connectivity. To get this very heterogeneous distribution, we can use the barabasi.game function in the igraph library. 
#' 
#' We can also use a community detection algorithm to find the most densely connected nodes within the graph.
#' Densely connected subgraphs are called communities justifying the name of these algorithm. There are many different types of community detection algorithms in igraph (https://www.sixhat.net/finding-communities-in-networks-with-r-and-igraph.html). 
#' 
#' Modularity measures the strength of division of a network into clusters and cummunities (modules). Networks with high modularity have dense connections between the nodes within modules but sparse connections between nodes in different modules. The “fast greedy” method, starts with each node belonging to a separate community and these are itteratively merged such that it yields the largest increase in the current value of modularity. 
#' 
#' I also use the walktrap and 'fast greedy' method. Walktrap tries to find densely connected subgraphs by using short random walks of 3-4-5 steps (we can specify how many steps to take in the function). The idea is that walks are more likely to remain in the same community because there are only a few edges which exist outside a given community. 
#' 
#'  
#' 
#' 
## --------------------------------------------------------------------------------------------------------------------------------
#?? barabasi.game
# ?walktrap.community 
set.seed(1234)

#generate graph with linear preferential attachment
g = barabasi.game(size, directed = F)

# plot g
plot(g, 
     vertex.color="light blue", 
     vertex.label.cex=.5,
     vertex.size=10*log(igraph::degree(g)))

# Find communities using walktrap algorithm 
community_walktrap <- walktrap.community(g, 
                                         steps = 3) # The length of the random walks to perform.

# list of nodes in the most densely connected subgraph extracted from the community_walktrap object
members_walktrap <- membership(community_walktrap)

# plot grap which highlights walktrap algorithm communities

plot(g,
vertex.color="light blue",     
vertex.size = 5, 
vertex.label.cex=.5,
mark.groups=list(members_walktrap), #A list of numeric vectors. The communities can be highlighted using colored polygons.      
mark.col="pink"
)


# Finding Communities using fast greedy algorithm 

community_fastgreedy <- fastgreedy.community(g)

# list of nodes in the most densely connected subgraph extracted from the community_fastgreedy object
members_fastgreedy  <- membership(community_fastgreedy)

# plot grap which highlights fast greedy communities 

plot(g,
vertex.color="light blue",     
vertex.size = 5, 
vertex.label.cex=.5,
mark.groups=list(members_fastgreedy), 
mark.col="yellow")




#' We can also use the sample_pa function in igraph to generate a graph using the BA-model. I find this more intutive as the arguments are more explicit. I have specified the number of nodes to use, the power of preferential attachment and the number of edges to add in each time step. 
#' 
#' I have specified power as 1 which depecits linear preferential attachment. And m = 1 will add one edge at each time step. 
#' 
## --------------------------------------------------------------------------------------------------------------------------------
# ? sample_pa
set.seed(1234)

g = sample_pa(size, 
              power = 1,
              m = 1,             ## for each new node 1 new links is created
              directed = F)

plot(g, vertex.color="light blue", 
     vertex.size = 10, 
     vertex.label.cex=.5)



#' 
#' Again, we can plot the degree distribution to visually check the 'rich gets richer'/power law property  of our graph. I have used 1000 nodes in this simulation to help make the distribution properties more visually pronounced. 
#' 
#' The skew with a long tail in the degree distribution is visually prominent. We can look at the actual values using the table command. There are 593 nodes (more than 50% of the nodes) which have a degree of 1, or are connected to only one other node. And there are only 68 nodes (less than 10%) which have a degree greater than 5.
#' 
#' 
## --------------------------------------------------------------------------------------------------------------------------------
set.seed(1234)
sizex = 1000
gx = sample_pa(sizex, power = 1, m = 1, directed = F)
#plot(gx, vertex.color="light blue", vertex.size = 5, vertex.label = NA)

d2 <- igraph::degree(gx)

# Frequency plot
b2 <- hist(d2, main=" graph", col="Gray")

# frequency table : 1st row gives degree and second row tells us how many nodes have that degree 
table(d2)

# no. of nodes with degrees greater than 5 
sum(table(d2)[5:15])

#' 
#' We can also plot the log-log represntation. The linear relationship (straight line) in the log-log plot is an indicator of the power law decay.
#' 
## --------------------------------------------------------------------------------------------------------------------------------

# x = the breaks/cutpoints in the histogram (15)
# y = frequency within each cell; we add 1 to take care of zeros  
# log = "xy" transforms x and y to a log-log scale
# type = "b" tell the plot function to include points and lines 

plot(1:length(b2$counts),b2$counts+1, xlab = "Degree",ylab = "Frequency", cex.lab = 1.5,main = "Scale-Free (log-log scale)", log = "xy", type = "b")



#' 
#' We can test whether our network follows a power law more formally using the fit_power_law function in igraph.According to the help, this function fits a power-law distribution to a vector containing samples from a distribution (that is assumed to follow a power-law of course). In a power-law distribution, it is generally assumed that P(X=x) is proportional to x ^ -(alpha), where alpha is greater than 1. Alpha is the exponent of the fitted power-law distribution. We expect its value to be 3 based on the derivation in the paper. As can be seen the value for our network is quite close to 3. 
#' 
#' The function also outputs the Kolmogorov-Smirnov test that compares the fitted distribution with the input vector. The p-value of the Kolmogorov-Smirnov test. Small p-values (less than 0.05) indicate that the test rejected the hypothesis that the original data could have been drawn from the fitted power-law distribution. The p value is .99 which means it we will not reject the hypothesis and confirms that our data follows a power law. 
#' 
## --------------------------------------------------------------------------------------------------------------------------------
#?fit_power_law
power2 <- fit_power_law(d2)

# exponent/alpha
power2$alpha

# test statistic of a Kolmogorov-Smirnov test
power2$KS.stat

# p value for the K.S. test at 5%
power2$KS.p


#' 
#' Calculating the same statistic for the random graph we generated in the beginning, we find that the test gives a p value of less than 0.05, correctly indicating that the test rejected the hypothesis that the original data could have been drawn from the fitted power-law distribution. 
#' 
## --------------------------------------------------------------------------------------------------------------------------------
power1 <- fit_power_law(d1,1)

# exponent/alpha
power1$alpha

# test statistic of a Kolmogorov-Smirnov test
power1$KS.stat

# p value for the K.S. test at 5%
power1$KS.p


#' Do states preferentially use some states as a policy source? 
#' 
#' The data used comes from SPID: State Policy Innovation and Diffusion Database on Dataverse (see: https://doi.org/10.1111/psj.12357). The edgelist reports the list of estimated latent diffusion ties between states in the US. Each entry in the data indicates that the origin state (origin_state) sent a directed policy diffusion tie to a destination  (destination_statenam) in the corresponding year. Ties are binary and directed. An alternative interpretation of this relationship is that the destination state use the origin state as a policy source in that year, depicting emulation. The time period goes from 1960-2014 and each year has 800 observations in each year. 
#' 
#' In the the example below, I have I use the dplyr library to subset the data so that only ties for 2014 are analyzed. I have also made destination_statenam the first column so the direction of the graph point to the source of the policy (or the orign state). 
#' 
## --------------------------------------------------------------------------------------------------------------------------------

# load object with data 
load("SPID_v1.0_network.RData")

# subset data to only include ties for 2014

y2014 <- x %>%
  filter(year == 2014) %>%
  select(destination_statenam, everything())
  

#' 
#' The plot of the network looks a bit messy but its still giving useful information. The sizing of the nodes which incorporates the in-degree distribution for each state is allowing us to identify 'hubs' for policy emulation. The nodes of states located on the outside of the network seem smaller than ones in the center and seem to depict that other states don't borrow from, say, Wyoming as much as from Californina.  
#' 
#' We can also plot the degree distributions. This doesn't really look like like a power law. Looking at the actual degree values which we can get using the table command, we find that the number of nodes are mostly similarl spread across the different degrees. A degree of 1 is observed for 3 states and a degree of 30 is observed for 3 states. There are a couple of states with degrees higher than 25 (6) as well as a couple with degrees less than 10 (10). If we look at log-log scale doesnt represent the power law shape either. 
#' 
#' However, it is important to note that in many real-world cases, the power-law behaviour kicks in only above a certain threshold value and it is not always the case that we'll see the prefect jump from extremely high degree to an extremely low degree. 
#' 
#' 
## --------------------------------------------------------------------------------------------------------------------------------
g <- graph.data.frame(y2014,directed=T)

set.seed(1234)
# plot g

plot(g, 
     vertex.color = "light blue", 
     vertex.label.cex = .4,
     vertex.size = 4*log(igraph::degree(g, mode = "in")),
     edge.arrow.size =.5)

# “in” for in-degree 
d2014 <- igraph::degree(g, mode = "in")

d2014

# frequency plot of degree  
hist_1 <- hist(d2014)

# table of distribution 
(table(d2014))

# find the top ten states with the highest degrees 
top_10_states = order(d2014, decreasing = TRUE )[1:10] 
d2014[top_10_states]

# log-log representation 
plot(1:length(hist_1$counts),hist_1$counts+1, xlab = "Degree",ylab = "Frequency", cex.lab = 1.5,main = "Scale-Free (log-log scale)", log = "xy", type = "b")




#' 
#' We can more formally test whether our network follows a power law using the Kolmogorov-Smirnov test. Remember if p value is less than 0.05, we can reject the null that our network data could have been drawn from a fitted power-law distribution.
#' 
## --------------------------------------------------------------------------------------------------------------------------------
power_y2014 <- fit_power_law(d2014, xmin=1)

# alpha/exponent
power_y2014$alpha

# test statistic of a Kolmogorov-Smirnov test
power_y2014$KS.stat

# p value for the KS statistic
power_y2014$KS.p

#' A differnt specification xmin = 1
#' 
## --------------------------------------------------------------------------------------------------------------------------------
power_y2014 <- fit_power_law(d2014, xmin=1)

# alpha/exponent
power_y2014$alpha

# test statistic of a Kolmogorov-Smirnov test
power_y2014$KS.stat

# p value for the KS statistic
power_y2014$KS.p


#' 
#' We can compare the ntework structure in 2014 with other years. Here I repeat all the steps I did for 2014 for the year 1960, which is the first year for which these latent ties are available. 
#' 
## --------------------------------------------------------------------------------------------------------------------------------
# subset data to only include ties for 1960 

# store data for year == 2014 in y1960
y1960 <- x %>%
  filter(year == 1960) %>%
  select(destination_statenam, everything())


#' 
#' The results are interesting. California is no longer the leader as the state from which other states borrow policies. It does not even figure in the top ten! In fact, for 1960, Louisiana, New York and Ohio have the highest degree distribution. 
#' 
#' The log-log scale doesn't really seem to the power law. 
#' 
## --------------------------------------------------------------------------------------------------------------------------------

g <- graph.data.frame(y1960,directed=T)

# plot g
plot(g, 
     vertex.color="light blue", 
     vertex.label.cex=.4,
     vertex.size=4*log(igraph::degree(g, mode = "in")),
     edge.arrow.size=.5)

# “in” for in-degree 
d1960 <- igraph::degree(g, mode = "in")

d1960

# frequency plot of degree  
hist_2 <- hist(d1960)

# table of distribution 
(table(d1960))

# find the top ten states with the highest degrees 
top_10_states = order(d1960, decreasing = TRUE )[1:10] 
d1960[top_10_states]

# log-log representation 
plot(1:length(hist_2$counts),hist_2$counts+1, xlab = "Degree",ylab = "Frequency", cex.lab = 1.5,main = "Scale-Free (log-log scale)", log = "xy", type = "b")




## --------------------------------------------------------------------------------------------------------------------------------
power_y1960 <- fit_power_law(d1960, xmin=1)

# alpha/ exponent
power_y1960$alpha

# test statistic of a Kolmogorov-Smirnov test
power_y1960$KS.stat

# p value for the KS statistic
power_y1960$KS.p


