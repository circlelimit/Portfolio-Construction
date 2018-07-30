### This R script contains all additonal functions that are used in the analysis

## Package management
# Check and install packages
pkg.list = c("MASS", "quadprog", "LiblineaR", "quantreg", "rqPen", "elasticnet", "glmnet", "beepr", "BatchGetSymbols")

is.installed = function(pkg.list){
  pkg.list %in% rownames(installed.packages())
}
# Install packages
if(any(!is.installed(pkg.list))){
  install.packages(pkg.list[!is.installed(pkg.list)])
}


## Data Generation

# Call: ff_ret(n, p)
# Inputs: n = # Trading days, p = # Assets
# Output: Returns a n by p matrix containing the FF-returns of p assets over n days
# This function simulates the Fama-French 3-Factor Model by generating the factors over n days
# and the 3 factor loadings and idiosyncratic risk for each asset as specified in Fan et al. (2008)
# In addtion, this function returns the true variance of the simulated Fama-French 3-Factor Model returns
# The assumptions are as specified in Fan et al. (2008)
ff_ret = function(n,p){
  # Error check
  if(missing(n) | missing(p)){
    stop("Please enter n = # Tradings days and p = # Assets.")
  }
  # Define the parameters specified by Fan et al. (2008)
  mu_b = matrix(c(0.7828, 0.5180, 0.4100), 3, 1)
  cov_b = matrix(c(0.02914, 0.02387, 0.01018, 0.02387, 0.05395, -0.00696, 0.010184, -0.006967, 0.086856), 3, 3)
  mu_f = matrix(c(0.02355, 0.01298, 0.02071), 3, 1)
  cov_f = matrix(c(1.2507, -0.0350, -0.2042, -0.0350, 0.3156, -0.0023, -0.2042, -0.0023, 0.1930), 3, 3)
  alpha = 3.3586
  theta = 0.1876
  threshold = 0.1950
  #n = 252 # for testing
  #p = 30 # for testing
  # Set seed
  #set.seed(123)
  # Generate returns of the 3 factors for time period 1<=i<=n (n by 3)
  f = mvrnorm(n = n, mu = mu_f, Sigma = cov_f)
  # Generate factor loadings B (p by 3) for each asset i for 1<=i<=p
  B = mvrnorm(n = p, mu = mu_b, Sigma = cov_b)
  #colMeans(B)
  # Generate p standard deviations from Gamma(alpha, theta), conditioned on a min of threshold
  sigmas = rgamma(n = p, shape = alpha, scale = theta)
  flag.indices = which(sigmas < threshold)
  sigmas[flag.indices] = threshold
  # Generate idiosyncratic risk for each asset i for 1<=j<=p at each period of time 1<=i<=n (n by p matrix)
  epsilon = mvrnorm(n = n, mu =matrix(numeric(p), p, 1) , Sigma = diag(sigmas))
  # Combine to get factor returns
  ret = f%*%t(B) + epsilon
  
  # Variance Covariance Matrix
  var = B%*%cov_f%*%t(B) + diag(sigmas)
  
  # Output is list containing the randomly generated returns and it's corresponding Var-Cov matrix
  list(ret,var)
}

# Call: trans.phi(ret)
# Inputs: n by p matrix containing the returns of p stocks over n periods
# Output: Transforms returns into Y and X variables for regression and outputs matrix [Y X]
# i.e. Y = R_p, X_i = R_p - R_i
trans.phi = function(ret){
  p = ncol(ret)
  n = nrow(ret)
  Y = data.frame(ret[,p])
  X = data.frame(matrix(numeric(n*(p-1)),n,p-1)) # initialise
  for(i in 1:(p-1)){
    X[,i] = Y - ret[,i]
  }
  out.data = cbind.data.frame(Y,X)
  names(out.data) = c("Y", paste0("X",as.character(1:(p-1))))
  return(out.data)
}


# Call: replace.ns(train, w.ns)
# Inputs: n by p matrix containing the training set, and the optimal no short sale portfolio weights
# Output: Replaces the last asset (asset p) with the returns of the no short sale portfolio
replace.ns = function(train, test){
  sc = var(train)
  Dmat = 2 * sc  # quadprog minimises half w'scw, so multiply by 2 to min portfolio var
  dvec = numeric(p1)
  Amat = t(rbind(rep(1,p1), diag(rep(1, p1), p1 , p1)))
  bvec = c(1, numeric(p1))
  qp = solve.QP(Dmat = Dmat, dvec = dvec, Amat = Amat, bvec = bvec, meq = 1)
  w.ns = qp$solution
  
  trainret.ns = as.matrix(train) %*% w.ns
  train.ns = cbind.data.frame(train[, -ncol(train)], trainret.ns)
  testret.ns = as.matrix(test) %*% w.ns
  test.ns = cbind.data.frame(test[, -ncol(test)], testret.ns)
  
  # Output
  list(train.ns, test.ns)
}

