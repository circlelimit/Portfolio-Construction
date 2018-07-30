# Portfolio-Construction
The purpose of this document is to demonstrate the use of regularised regression methods in constructing Markowitz Global Minimum Variance (GMV) Portfolios. Traditionally, GMV portfolios are constructed by solving a quadratic optimisation problem. However, there are two issues with this: (1) when the estimated variance-covariance matrix is non-singular, the quadratic optimisation problem cannot be solved using the usual method, (2) when the portfolio constructed is large, the estimation error of the variance-covariance will be large. These issues can be resolved using a regularised regression approach. By reframing the portfolio optimisation problem into a regression problem, we are able to make use of the many efficient regression solving algorithms to work around the problem of high dimensionality. Even when the estimated variance-covariance matrix is non-singular, these the regression constructed portfolios are able to attain lower risk profiles than both the traditional GMV portfolio and the equally weighted portfolio.

# Dependencies
(1) MASS
<br />(2) quadprog
<br />(3) LiblineaR
<br />(4) quantreg
<br />(5) rqPen
<br />(6) elasticnet
<br />(7) glmnet
<br />(8) beepr
<br />(9) BatchGetSymbols

# Files
(1) getPriceData.r pulls the relevant stock prices and randomly chooses returns of 500 stocks.
<br />(2) functionlist.r contains functions used in the project.
<br />(3) Simulation_Studies.RMD constructs GMV portfolios from generated data. This allows us to compare the oracle risk with the empirical risk.
<br />(4) Empirical_Studies.RMD makes use of the real data collected using getPriceData.r.

# Additional
The full report can be found at https://drive.google.com/open?id=1Rzy1evMI74zJvo5c_6RndMpP4hciftks
Note that some of the .r files used in the full report is not produced above. They are omitted because:
<br />(1) they are very similar to the file produced above, with only slight modifications,
<br />(2) they contain simple plotting functions.
