#install.packages("plot3D")
library(plot3D)

# u <- M$x ; v <- M$y
# b <- 0.4; r <- 1 - b^2; w <- sqrt(r)
# D <- b*((w*cosh(b*u))^2 + (b*sin(w*v))^2)
# x <- -u + (2*r*cosh(b*u)*sinh(b*u)) / D
# y <- (2*w*cosh(b*u)*(-(w*cos(v)*cos(w*v)) - sin(v)*sin(w*v))) / D
# z <- (2*w*cosh(b*u)*(-(w*sin(v)*cos(w*v)) + cos(v)*sin(w*v))) / D
# surf3D(x, y, z, colvar = sqrt(x + 8.3), colkey = FALSE,
#        border = "black", box = FALSE)

e = 1
t = 1
zmax=2

colpal=function(){
  maxcol=112
  mn=round(min(ability)/zmax*100)
  mx=round(max(ability)/2*100)
  if (mn==mx && (mn==0)) {
    return(gg2.col(maxcol)[1])
  } else if (mn==mx && (mn==0)) {
    return(gg2.col(maxcol)[100])
  } else {
    return(gg2.col(maxcol)[mn:mx])
  }
}

effort = seq(0,1,length.out=50)
time = seq(0,1,length.out=50)
M = mesh(effort, time)

e=.5
t=.5
ability = e*M$x + t*M$y
surf3D(M$x, M$y, ability, colvar = ability,
       colkey = FALSE, box=T, col=colpal(),
       facets=FALSE, bty="f", xlab="effort", ylab="time", zlab="ability",
       main="growth", zlim=c(0,zmax))
par(new=T)
e=1
t=1
ability = e*M$x + t*M$y
surf3D(M$x, M$y, ability, colvar = ability,
       colkey = FALSE, box=T, col=colpal(),
       facets=FALSE, bty="n", xlab="effort", ylab="time", zlab="ability",
       main="", zlim=c(0,zmax))

ability = apply(e*M$x + t*M$y, c(1,2), function(x){return(min(x,1))})
surf3D(M$x, M$y, ability, colvar = ability,
       colkey = FALSE, box=T, col=colpal(),
       facets=FALSE, bty="f", xlab="effort", ylab="time", zlab="ability",
       main="growth with ceiling", zlim=c(0,zmax))
par(new=T)
ability = 1 + apply(e*M$x + t*M$y, c(1,2), function(x){return(min(x,1))})
surf3D(M$x, M$y, ability, colvar = ability,
       colkey = FALSE, box=T, col=colpal(),
       facets=FALSE, bty="n", xlab="effort", ylab="time", zlab="ability",
       main="", zlim=c(0,zmax))

ability = apply(e*M$x + t*M$y, c(1,2), function(x){return(0)})
surf3D(M$x, M$y, ability, colvar=FALSE,
       colkey = FALSE, box=T, col=colpal(),
       facets=FALSE, bty="f", xlab="effort", ylab="time", zlab="ability",
       main="fixed", zlim=c(0,zmax))
par(new=T)
ability = ability + 1
#ability = apply(e*M$x + t*M$y, c(1,2), function(x){return(1)})
surf3D(M$x, M$y, ability, colvar=FALSE,
       colkey = FALSE, box=T, col=colpal(),
       facets=FALSE, bty="n", xlab="effort", ylab="time", zlab="ability",
       main="", zlim=c(0,zmax))
par(new=T)
ability = ability + 1
#ability = apply(e*M$x + t*M$y, c(1,2), function(x){return(2)})
surf3D(M$x, M$y, ability, colvar=FALSE,
       colkey = FALSE, box=T, col=colpal(),
       facets=FALSE, bty="n", xlab="effort", ylab="time", zlab="ability",
       main="", zlim=c(0,zmax))

e=0
ability = e*M$x + t*M$y
surf3D(M$x, M$y, ability, colvar = ability,
       colkey = FALSE, box=T, col=colpal(),
       facets=FALSE, bty="f", xlab="effort", ylab="time", zlab="ability",
       main="growth only over time", zlim=c(0,zmax))
par(new=T)
ability = 1 + e*M$x + t*M$y
surf3D(M$x, M$y, ability, colvar = ability,
       colkey = FALSE, box=T, col=colpal(),
       facets=FALSE, bty="n", xlab="", ylab="", zlab="",
       main="", zlim=c(0,zmax))

e=1
t=0
ability = e*M$x + t*M$y
surf3D(M$x, M$y, ability, colvar = ability,
       colkey = FALSE, box=T, col=colpal(),
       facets=FALSE, bty="f", xlab="effort", ylab="time", zlab="ability",
       main="growth only through effort", zlim=c(0,zmax))
par(new=T)
ability = 1+e*M$x + t*M$y
surf3D(M$x, M$y, ability, colvar = ability,
       colkey = FALSE, box=T, col=colpal(),
       facets=FALSE, bty="f", xlab="effort", ylab="time", zlab="ability",
       main="growth only through effort", zlim=c(0,zmax))

# e=1
# t=1
# ability = apply(M$x, c(1,2),function(x){return(exp(x)-1}) +
#   apply(M$y, c(1,2),function(x){return(exp(x)-1})
# surf3D(M$x, M$y, ability, colvar = ability,
#        colkey = FALSE, box=T, col=colpal(),
#        facets=FALSE, bty="f", xlab="effort", ylab="time", zlab="ability",
#        main="growth only through effort", zlim=c(0,zmax))