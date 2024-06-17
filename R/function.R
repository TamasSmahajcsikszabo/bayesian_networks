covariance <- function(x, y) {
    Ex <- mean(x, na.rm = TRUE)
    Ey <- mean(y, na.rm = TRUE)
    n <- length(x)
    covN <- 0
    for (i in seq(1, n)) {
        covN <- covN + (x[i] - Ex) * (y[i] - Ey)
    }
    cov <- covN / n

    return(cov)
}

x  <-  rnorm(100) + 12
y <- x + rnorm(100) * (-2) * 1/rnorm(100)

plot(x,y)
covariance(x,y)
cov(x,y)
