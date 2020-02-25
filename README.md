
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
#> Warning: replacing previous import 'magrittr::set_names' by
#> 'rlang::set_names' when loading 'powder'
#> Warning: replacing previous import 'magrittr::extract' by 'tidyr::extract'
#> when loading 'powder'
```

### One set of parameters

``` r
diff <- 10
sigma <- 10
delta <- diff/sigma

pwr.t.test(d = delta, power = 0.8, type = "one.sample")
#> 
#>      One-sample t test power calculation 
#> 
#>               n = 9.93785
#>               d = 1
#>       sig.level = 0.05
#>           power = 0.8
#>     alternative = two.sided
# sample - power plot
#pwr.t.test(d = delta, power = 0.8, type = "one.sample") %>% plot()
```

### More than one set of parameters

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
#> Warning: Unknown columns: `n`
#> # A tibble: 9 x 11
#>    diff sigma    sd delta query pwr_rawh     n sig.level power type 
#>   <dbl> <dbl> <dbl> <dbl> <chr> <list>   <dbl>     <dbl> <dbl> <chr>
#> 1    10  10    10   1     n     <pwr.ht~  9.94      0.05   0.8 one.~
#> 2    10  12.5  12.5 0.8   n     <pwr.ht~ 14.3       0.05   0.8 one.~
#> 3    10  15    15   0.667 n     <pwr.ht~ 19.7       0.05   0.8 one.~
#> 4    20  10    10   2     n     <pwr.ht~  4.22      0.05   0.8 one.~
#> 5    20  12.5  12.5 1.6   n     <pwr.ht~  5.28      0.05   0.8 one.~
#> 6    20  15    15   1.33  n     <pwr.ht~  6.58      0.05   0.8 one.~
#> 7    30  10    10   3     n     <pwr.ht~  3.14      0.05   0.8 one.~
#> 8    30  12.5  12.5 2.4   n     <pwr.ht~  3.64      0.05   0.8 one.~
#> 9    30  15    15   2     n     <pwr.ht~  4.22      0.05   0.8 one.~
#> # ... with 1 more variable: alternative <chr>

#create ggplot
eg1 %>%
  pwr_tidy(test_function = pwr.t.test) %>%
  pwr_plot(x = diff,y = n,group = sigma)
#> Warning: Unknown columns: `n`
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
#> Warning: Unknown columns: `power`
#> # A tibble: 18 x 11
#>     diff sigma    sd delta query pwr_rawh     n sig.level power type 
#>    <dbl> <dbl> <dbl> <dbl> <chr> <list>   <dbl>     <dbl> <dbl> <chr>
#>  1     5    10    10   0.5 power <pwr.ht~    10      0.05 0.293 one.~
#>  2    10    10    10   1   power <pwr.ht~    10      0.05 0.803 one.~
#>  3    15    10    10   1.5 power <pwr.ht~    10      0.05 0.987 one.~
#>  4     5    10    10   0.5 power <pwr.ht~    12      0.05 0.353 one.~
#>  5    10    10    10   1   power <pwr.ht~    12      0.05 0.883 one.~
#>  6    15    10    10   1.5 power <pwr.ht~    12      0.05 0.997 one.~
#>  7     5    10    10   0.5 power <pwr.ht~    14      0.05 0.410 one.~
#>  8    10    10    10   1   power <pwr.ht~    14      0.05 0.932 one.~
#>  9    15    10    10   1.5 power <pwr.ht~    14      0.05 0.999 one.~
#> 10     5    10    10   0.5 power <pwr.ht~    16      0.05 0.465 one.~
#> 11    10    10    10   1   power <pwr.ht~    16      0.05 0.962 one.~
#> 12    15    10    10   1.5 power <pwr.ht~    16      0.05 1.000 one.~
#> 13     5    10    10   0.5 power <pwr.ht~    18      0.05 0.516 one.~
#> 14    10    10    10   1   power <pwr.ht~    18      0.05 0.979 one.~
#> 15    15    10    10   1.5 power <pwr.ht~    18      0.05 1.000 one.~
#> 16     5    10    10   0.5 power <pwr.ht~    20      0.05 0.565 one.~
#> 17    10    10    10   1   power <pwr.ht~    20      0.05 0.989 one.~
#> 18    15    10    10   1.5 power <pwr.ht~    20      0.05 1.000 one.~
#> # ... with 1 more variable: alternative <chr>

#create ggplot
eg2 %>%
  pwr_tidy(test_function = pwr.t.test) %>%
  pwr_plot(x = n,y = power,group=diff)
#> Warning: Unknown columns: `power`
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
#>   Andree Valle-Campos (2020). powder: A Tidy Extension for Power
#>   Analysis. R package version 0.0.0.9000.
#>   https://avallecam.github.io/powder/
#> 
#> A BibTeX entry for LaTeX users is
#> 
#>   @Manual{,
#>     title = {powder: A Tidy Extension for Power Analysis},
#>     author = {Andree Valle-Campos},
#>     year = {2020},
#>     note = {R package version 0.0.0.9000},
#>     url = {https://avallecam.github.io/powder/},
#>   }
```
