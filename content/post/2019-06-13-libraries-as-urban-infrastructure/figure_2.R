#### Figure 2 ##################################################################

library(sf)
library(tidyverse)
library(cancensus)
library(units)
library(extrafont)
library(tmap)

### Helper functions ###########################################################

st_intersect_summarize <-
  function(data,
           poly,
           group_vars,
           population,
           sum_vars,
           mean_vars) {
    pop <- enquo(population)
    
    data <- data %>%
      mutate(CT_area = st_area(.))
    
    intersects <- suppressWarnings(st_intersection(data, poly)) %>%
      mutate(
        int_area_pct = st_area(.data$geometry) / .data$CT_area,
        population_int = !!pop * int_area_pct
      ) %>%
      group_by(!!!group_vars)
    
    population <- intersects %>%
      summarize(!!pop := sum(population_int, na.rm = TRUE))
    
    sums <- intersects %>%
      summarize_at(sum_vars, ~ {
        sum(. * int_area_pct, na.rm = TRUE) /
          sum(population_int, na.rm = TRUE)
      })
    
    means <- intersects %>%
      summarize_at(mean_vars, ~ {
        sum(. * population_int, na.rm = TRUE) / sum(population_int, na.rm = TRUE)
      })
    
    suppressMessages(reduce(
      list(
        population,
        st_drop_geometry(sums),
        st_drop_geometry(means)
      ),
      full_join
    ))
    
  }


### Create library_service_comparison ##########################################

library_service_comparison_2006 <- st_intersect_summarize(
  CTs_2006,
  service_areas_2006,
  group_vars = vars(CMA_name, library, PR_UID),
  population = population,
  sum_vars = vars(housing_need, visible_minorities),
  mean_vars = vars(unemployed_pct, med_income)
) %>%
  ungroup() %>%
  mutate(unemployed_pct = unemployed_pct * 0.01) %>%
  drop_units() %>%
  mutate(
    region = case_when(
      PR_UID == 59 ~ "BC",
      PR_UID == 48 | PR_UID == 47 | PR_UID == 46 ~ "Prairies",
      PR_UID == 35 ~ "Ontario",
      PR_UID == 24 ~ "Quebec",
      PR_UID == 12 | PR_UID == 13 ~ "Atlantic"
    )
  )

library_service_comparison_2016 <-
  st_intersect_summarize(
    CTs_2016,
    service_areas_2016,
    group_vars = vars(CMA_name, library, PR_UID),
    population = population,
    sum_vars = vars(housing_need, visible_minorities),
    mean_vars = vars(unemployed_pct, med_income)
  ) %>%
  ungroup() %>%
  mutate(unemployed_pct = unemployed_pct * 0.01) %>%
  drop_units() %>%
  mutate(
    region = case_when(
      PR_UID == 59 ~ "BC",
      PR_UID == 48 | PR_UID == 47 | PR_UID == 46 ~ "Prairies",
      PR_UID == 35 ~ "Ontario",
      PR_UID == 24 ~ "Quebec",
      PR_UID == 12 | PR_UID == 13 ~ "Atlantic"
    )
  )

library_service_comparison <-
  rbind(
    library_service_comparison_2006 %>% mutate(date = "2006"),
    library_service_comparison_2016 %>% mutate(date = "2016")
  ) %>%
  drop_units()
