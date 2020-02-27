#' @title powder: A Tidy Extension for Power Analysis
#'
#' @description Create tables and plots for power and sample size calculations from a range of required parameters. All of the parameters accepts a range or sequence of numbers. Usable with pwr and stats::power.
#'
#' @describeIn pwr_grid
#'
#' @param n Number of observations (per sample)
#' @param diff Difference between the means
#' @param sigma Standard deviation
#' @param d Effect size (Cohen's d)
#' @param sig.level Significance level (Type I error probability)
#' @param power Power of test (1 minus Type II error probability)
#' @param type Type of t test : one- two- or paired-samples
#' @param alternative a character string specifying the alternative hypothesis, must be one of "two.sided" (default), "greater" or "less"
#'
#' @import dplyr
#' @import tidyr
#' @import broom
#' @import magrittr
#' @import pwr
#' @import rlang
#'
#' @return canal endemico, union y grafico
#'
#' @export pwr_grid
#' @export pwr_tidy
#' @export pwr_plot
#'
#' @examples
#'
#' library(tidyverse)
#' library(pwr)
#' library(powder)
#'
#' # stata
#' # power onemean 20, diff(10 20 30) sd(10 12.5 15)
#' eg1 <- pwr_grid(n = NULL,
#'                 diff = c(10,20,30),
#'                 sigma = c(10,12.5,15),
#'                 d = NULL,
#'                 sig.level = 0.05,
#'                 power = 0.8,
#'                 type = "one.sample",
#'                 alternative = "two.sided")
#'
#' eg1 %>% pwr_tidy(test_function = pwr.t.test)
#'
#' eg1 %>%
#'   pwr_tidy(test_function = pwr.t.test) %>%
#'   pwr_plot(x = diff,y = n,group = sigma)
#'
#' # stata
#' # power onemean 20, diff(5 (5) 15) sd(10) n(10 (2) 20)
#' eg2 <- pwr_grid(n = seq(from = 10,to = 20,by = 2),
#'                 diff = seq(from = 5,to = 15,by = 5),
#'                 sigma = 10,
#'                 d = NULL,
#'                 sig.level = 0.05,
#'                 #power = 0.8,
#'                 type = "one.sample",
#'                 alternative = "two.sided")
#'
#' eg2 %>% pwr_tidy(test_function = pwr.t.test)
#'
#' eg2 %>%
#'   pwr_tidy(test_function = pwr.t.test) %>%
#'   pwr_plot(x = n,y = power,group=diff)
#'
#' # stata
#' # power onemean 100, n(10 20 30) power(0.8) sd(10 12.5 15)
#' eg3 <- pwr_grid(n=c(10,20,30),
#'                 #diff=c(10,20,30),
#'                 sigma=c(10,12.5,15),
#'                 d=NULL,
#'                 sig.level=0.05,
#'                 power=0.8,
#'                 type="one.sample",
#'                 alternative="two.sided")
#'
#' eg3 %>% pwr_tidy(test_function = power.t.test)
#'
#' eg3 %>%
#'   pwr_tidy(test_function = power.t.test) %>%
#'   pwr_plot(x = n,y = delta,group=sigma)
#'
pwr_grid <- function(k=NULL,
                     n=NULL,
                     n1=NULL,n2=NULL,
                     N=NULL,
                     h=NULL,
                     f=NULL,
                     f2=NULL,
                     r=NULL,
                     w=NULL,
                     diff=NULL,sigma=NULL,d=NULL,
                     df=NULL,
                     u=NULL,
                     v=NULL,
                     sig.level=0.05,
                     power=NULL,
                     type=NULL,
                     alternative=NULL) {

  dbx <- expand_grid(
    k=k,
    n=n,
    n1=n1,n2=n2,
    N=N,
    h=h,
    f=f,
    f2=f2,
    r=r,
    w=w,
    diff=diff,
    df=df,
    u=u,
    v=v,
    sigma=sigma,
    d=d,
    sig.level=sig.level,
    power=power,
    type=type,
    alternative=alternative
  ) %>%
    mutate(sd=sigma)

  if (!is_in("d",colnames(dbx)) & !is_in("diff",colnames(dbx))) {
    dbx <- dbx
  }

  if (!is_in("d",colnames(dbx)) & is_in("diff",colnames(dbx))) {
    dbx <- dbx %>%
      mutate(d=diff/sigma,
             delta=d)
  }

  dbx

}

#' @describeIn pwr_grid create table with parameters and calculations
#' @inheritParams pwr_grid
#' @param pwr_grid outcome of pwr_grid function
#' @param test_function function to calculate power from pwr or stats package

pwr_tidy <- function(pwr_grid,test_function) {

  data <- pwr_grid

  list_names <- rlang::fn_fmls(fn = test_function) %>% pluck(names)
  target_names <- colnames(data)

  query_name <- setdiff(list_names,target_names)[1] # this tells what I want
  #setdiff(target_names,list_names) # this tells
  intersect_names <- intersect(list_names,target_names)

  dbx <- data %>%
    mutate(query=query_name) %>%
    mutate(pwr_rawh=pmap(.l = select(.,one_of(list_names)),
                         .f = test_function),
           pwr_tidy=map(.x = pwr_rawh,.f = tidy),
           pwr_tidy=map(.x = pwr_tidy,.f = ~select(.x,-one_of(intersect_names)))
    ) %>%
    unnest(cols = c(pwr_tidy)) %>%
    select(-pwr_rawh)

  if (is_in("d",colnames(dbx)) & is_in("delta",colnames(dbx))) {
    dbx <- dbx %>%
      select(-d)
  }

  if (is_in("sd",colnames(dbx)) & is_in("sigma",colnames(dbx))) {
    dbx <- dbx %>%
      select(-sd)
  }

  dbx

}

#' @describeIn pwr_grid create diagnostic plot
#' @inheritParams pwr_grid
#' @param pwr_tidy outcome of pwr_tidy function
#' @param x x axis
#' @param y y axis
#' @param group colour variable

pwr_plot <- function(pwr_tidy,x,y,group) {

  dbx <- pwr_tidy
  c_x <- enquo(x)
  c_y <- enquo(y)
  c_group <- enquo(group)

  dbx %>%
    #mutate(f_group=as.factor(!!c_group)) %>%
    #ggplot(aes(x = !!c_x, y = !!c_y, color = f_group, group=f_group)) +
    ggplot(aes(x = !!c_x, y = !!c_y, color = !!c_group, group=!!c_group)) +
    geom_point() +
    geom_line() +
    scale_color_viridis_c() +
    #scale_color_viridis_d() +
    theme_bw()

}
