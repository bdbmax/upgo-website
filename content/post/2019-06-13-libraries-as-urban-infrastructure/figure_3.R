#### Figure 3 ##################################################################

library(sf)
library(tidyverse)
library(units)
library(extrafont)


### Create tidy_summary ########################################################

## Summaries by weighted mean (population)

summary_2016_weighted <-
  library_service_comparison_2016 %>%
  st_drop_geometry() %>%
  group_by(library) %>%
  summarize_at(
    c(
      "housing_need",
      "visible_minorities",
      "unemployed_pct",
      "med_income"
    ),
    ~ {
      sum(. * population, na.rm = TRUE) /
        sum(population, na.rm = TRUE)
    }
  )

summary_2006_weighted <-
  library_service_comparison_2006 %>%
  st_drop_geometry() %>%
  group_by(library) %>%
  summarize_at(
    c(
      "housing_need",
      "visible_minorities",
      "unemployed_pct",
      "med_income"
    ),
    ~ {
      sum(. * population, na.rm = TRUE) /
        sum(population, na.rm = TRUE)
    }
  )


## Tidying summary data

library_service_comparison_tidy <-
  gather(
    library_service_comparison,
    housing_need,
    visible_minorities,
    unemployed_pct,
    med_income,
    key = "census_variable",
    value = "value"
  ) %>%
  drop_units()

tidy_summary_2006 <-
  gather(
    summary_2006_weighted,
    housing_need,
    visible_minorities,
    unemployed_pct,
    med_income,
    key = "census_variable",
    value = "value"
  ) %>%
  mutate(date = "2006") %>%
  drop_units()

tidy_summary_2016 <-
  gather(
    summary_2016_weighted,
    housing_need,
    visible_minorities,
    unemployed_pct,
    med_income,
    key = "census_variable",
    value = "value"
  ) %>%
  mutate(date = "2016") %>%
  drop_units()

tidy_summary <- rbind(tidy_summary_2006, tidy_summary_2016)

rm(tidy_summary_2006, tidy_summary_2016)