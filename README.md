
<!-- README.md is generated from README.Rmd. Please edit that file -->

# powder

**Author:** [Andree Valle Campos](https://twitter.com/avallecam)
<a href="https://orcid.org/0000-0002-7779-481X" target="orcid.widget">
<image class="orcid" src="https://members.orcid.org/sites/default/files/vector_iD_icon.svg" height="16"></a>
<br/> **License:** [MIT](https://opensource.org/licenses/MIT)<br/>

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/powder)](https://cran.r-project.org/package=powder)
<!-- badges: end -->

## Overview

The goal of `powder` is to complement **power** and **sample size**
calculations:

  - for more than one set of parameters, and

  - create tidy output tables and plots from them.

## Installation

You can install the developing version of `powder` using:

``` r
if(!require("devtools")) install.packages("devtools")
devtools::install_github("avallecam/powder")
```

<!--

You can install the released version of powder from [CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("powder")
```

-->

## Structure

`powder` consist of three main functions:

  - `pwr_grid`: creates a tibble from all combination of input
    parameters using `tidyr::expand_grid`.

  - `pwr_tidy`: creates a `broom::tidy()` output from the calculations
    of all input parameters using `purrr::pmap`.

  - `pwr_plot`: create a `ggplot` with input parameters and calculated
    value (sample size, power or effect size)

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(tidyverse)
#> Warning: package 'ggplot2' was built under R version 3.6.2
library(magrittr)
library(broom)
library(pwr)
library(powder)
#> Warning: replacing previous import 'magrittr::extract' by 'tidyr::extract'
#> when loading 'powder'
```

### with one set of parameters

``` r
diff <- 10
sigma <- 10
delta <- diff/sigma

pwr.t.test(d = delta, power = 0.8, type = "one.sample") %>% tidy()
#> # A tibble: 1 x 3
#>       n sig.level power
#>   <dbl>     <dbl> <dbl>
#> 1  9.94      0.05   0.8
# power.t.test(d = delta, power = 0.8, type = "one.sample") %>% tidy()
# pwr.t.test(d = delta, power = 0.8, type = "one.sample") %>% plot()
```

### with more than one set of parameters

#### sample size

``` r
# stata
# power onemean 20, diff(10 20 30) sd(10 12.5 15)
eg1 <- pwr_grid(n = NULL,
                diff = c(10,20,30),
                sigma = c(10,12.5,15),
                d = NULL,
                sig.level = 0.05,
                power = 0.8,
                type = "one.sample",
                alternative = "two.sided")

#create tidytable
eg1 %>% pwr_tidy(test_function = pwr.t.test)
#> # A tibble: 9 x 9
#>    diff sigma type       alternative     d pwr_rawh       n sig.level power
#>   <dbl> <dbl> <chr>      <chr>       <dbl> <list>     <dbl>     <dbl> <dbl>
#> 1    10  10   one.sample two.sided   1     <pwr.htst>  9.94      0.05   0.8
#> 2    10  12.5 one.sample two.sided   0.8   <pwr.htst> 14.3       0.05   0.8
#> 3    10  15   one.sample two.sided   0.667 <pwr.htst> 19.7       0.05   0.8
#> 4    20  10   one.sample two.sided   2     <pwr.htst>  4.22      0.05   0.8
#> 5    20  12.5 one.sample two.sided   1.6   <pwr.htst>  5.28      0.05   0.8
#> 6    20  15   one.sample two.sided   1.33  <pwr.htst>  6.58      0.05   0.8
#> 7    30  10   one.sample two.sided   3     <pwr.htst>  3.14      0.05   0.8
#> 8    30  12.5 one.sample two.sided   2.4   <pwr.htst>  3.64      0.05   0.8
#> 9    30  15   one.sample two.sided   2     <pwr.htst>  4.22      0.05   0.8

#create ggplot
eg1 %>%
  pwr_tidy(test_function = pwr.t.test) %>%
  pwr_plot(x = diff,y = n,group = sigma)
```

<img src="man/figures/README-unnamed-chunk-3-1.png" width="100%" />

#### power

``` r
# stata
# power onemean 20, diff(5 (5) 15) sd(10) n(10 (2) 20)
eg2 <- pwr_grid(n = seq(from = 10,to = 20,by = 2),
                diff = seq(from = 5,to = 15,by = 5),
                sigma = 10,
                d = NULL,
                sig.level = 0.05,
                #power = 0.8,
                type = "one.sample",
                alternative = "two.sided")

#create tidytable
eg2 %>% pwr_tidy(test_function = pwr.t.test)
#> # A tibble: 18 x 9
#>     diff sigma type       alternative     d pwr_rawh      n sig.level power
#>    <dbl> <dbl> <chr>      <chr>       <dbl> <list>    <dbl>     <dbl> <dbl>
#>  1     5    10 one.sample two.sided     0.5 <pwr.hts~    10      0.05 0.293
#>  2    10    10 one.sample two.sided     1   <pwr.hts~    10      0.05 0.803
#>  3    15    10 one.sample two.sided     1.5 <pwr.hts~    10      0.05 0.987
#>  4     5    10 one.sample two.sided     0.5 <pwr.hts~    12      0.05 0.353
#>  5    10    10 one.sample two.sided     1   <pwr.hts~    12      0.05 0.883
#>  6    15    10 one.sample two.sided     1.5 <pwr.hts~    12      0.05 0.997
#>  7     5    10 one.sample two.sided     0.5 <pwr.hts~    14      0.05 0.410
#>  8    10    10 one.sample two.sided     1   <pwr.hts~    14      0.05 0.932
#>  9    15    10 one.sample two.sided     1.5 <pwr.hts~    14      0.05 0.999
#> 10     5    10 one.sample two.sided     0.5 <pwr.hts~    16      0.05 0.465
#> 11    10    10 one.sample two.sided     1   <pwr.hts~    16      0.05 0.962
#> 12    15    10 one.sample two.sided     1.5 <pwr.hts~    16      0.05 1.000
#> 13     5    10 one.sample two.sided     0.5 <pwr.hts~    18      0.05 0.516
#> 14    10    10 one.sample two.sided     1   <pwr.hts~    18      0.05 0.979
#> 15    15    10 one.sample two.sided     1.5 <pwr.hts~    18      0.05 1.000
#> 16     5    10 one.sample two.sided     0.5 <pwr.hts~    20      0.05 0.565
#> 17    10    10 one.sample two.sided     1   <pwr.hts~    20      0.05 0.989
#> 18    15    10 one.sample two.sided     1.5 <pwr.hts~    20      0.05 1.000

#create ggplot
eg2 %>%
  pwr_tidy(test_function = pwr.t.test) %>%
  pwr_plot(x = n,y = power,group=diff)
```

<img src="man/figures/README-unnamed-chunk-4-1.png" width="100%" />

## References

Stephane Champely (2018). pwr: Basic Functions for Power Analysis. R
package version 1.2-2. <https://CRAN.R-project.org/package=pwr>

## Citation

``` r
citation("powder")
#> 
#> To cite package 'powder' in publications use:
#> 
#>   Andree Valle-Campos (2020). powder: Complemetary Tidy Functions
#>   for Power Analysis using pwr and stats::power. R package version
#>   0.0.0.9000.
#> 
#> A BibTeX entry for LaTeX users is
#> 
#>   @Manual{,
#>     title = {powder: Complemetary Tidy Functions for Power Analysis using pwr and stats::power},
#>     author = {Andree Valle-Campos},
#>     year = {2020},
#>     note = {R package version 0.0.0.9000},
#>   }
```
