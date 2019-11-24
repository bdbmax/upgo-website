#### Figure 1 ##################################################################

library(sf)
library(tidyverse)
library(cancensus)
library(units)
library(extrafont)
library(tmap)


### Helper functions ###########################################################

st_erase <- function(x, y) st_difference(x, st_union(st_combine(y)))

make_library_service_areas <- function(libraries, CMAs) {
  lib_buffer <-
    st_join(libraries, CMAs) %>%
    group_by(CMA_name) %>%
    summarize(library = TRUE,
              geometry = st_union(geometry)) %>%
    slice(1:nrow(.)) %>% 
    st_buffer(1000)
  
  diff_lib <- suppressWarnings(
    st_erase(CMAs, lib_buffer) %>%
      mutate(library = FALSE) %>%
      select(CMA_name, library, geometry)
  )
  
  rbind(lib_buffer, diff_lib)
}


### Import libraries ###########################################################

libraries <- suppressWarnings(
  read_csv("R_data/Canadian_libraries.csv") %>%
    st_as_sf(coords = c("Longitude", "Latitude"), crs = 4326) %>%
    st_transform(3347)
)


### Import water ###############################################################

water <- read_sf("R_data", "lhy_000c16a_e")
coastal_water <- read_sf("R_data", "lhy_000h16a_e")

water_BC <- st_union(st_combine(filter(water, PRUID == "59")))
coastal_water_BC <- st_union(st_combine(filter(coastal_water, PRUID == "59")))

water_AB <- st_union(st_combine(filter(water, PRUID == "48"))) 
coastal_water_AB <- st_union(st_combine(filter(coastal_water, PRUID == "48")))

water_ON <- st_union(st_combine(filter(water, PRUID == "35")))
coastal_water_ON <- st_union(st_combine(filter(coastal_water, PRUID == "35")))

water_QC <- st_union(st_combine(filter(water, PRUID == "24")))
coastal_water_QC <- st_union(st_combine(filter(coastal_water, PRUID == "24")))

rm(water, coastal_water)


### Import and process CMAs_2006 and service_areas_2006 ########################

CMAs_2006 <-
  get_census(
    dataset = 'CA06',
    regions = list(C = "Canada"),
    level = 'CMA',
    geo_format = "sf"
  ) %>%
  st_transform(3347) %>% 
  filter(Type == "CMA") %>%
  select(GeoUID, CMA_name = name)

libraries_2006 <-
  libraries[lengths(st_within(libraries, CMAs_2006)) > 0,]

CMAs_2006 <-
  CMAs_2006[lengths(st_contains(CMAs_2006, libraries_2006)) > 0,] %>%
  mutate(
    CMA_name = ifelse(str_detect(CMA_name, "Mont"), "Montreal (B)", CMA_name),
    CMA_name = ifelse(CMA_name == "Abbotsford (B)",
                      "Abbotsford - Mission (B)", CMA_name),
    CMA_name = ifelse(
      CMA_name == "Kitchener (B)",
      "Kitchener - Cambridge - Waterloo (B)",
      CMA_name
    )
  )

service_areas_2006 <- make_library_service_areas(libraries_2006, CMAs_2006)


### Import and process CTs_2006 ################################################

CTs_2006 <-
  get_census(
    dataset = "CA06",
    regions = list(C = "Canada"),
    level = "CT",
    vectors = c(
      "v_CA06_582",
      "v_CA06_2051",
      "v_CA06_2056",
      "v_CA06_1785",
      "v_CA06_1303"
    ),
    geo_format = "sf"
  ) %>%
  st_transform(3347) %>%
  filter(Type == "CT") %>%
  select(GeoUID, PR_UID, CMA_UID, Population, contains("v_CA")) %>%
  mutate(CMA_UID = ifelse(CMA_UID == "24505" |
                            CMA_UID == "35505", "505", CMA_UID)) %>%
  inner_join(st_drop_geometry(CMAs_2006), by = c("CMA_UID" = "GeoUID")) %>%
  select(GeoUID, PR_UID, CMA_UID, CMA_name, everything()) %>%
  set_names(
    c(
      "Geo_UID",
      "PR_UID",
      "CMA_UID",
      "CMA_name",
      "population",
      "unemployed_pct",
      "housing_need_rent",
      "housing_need_own",
      "med_income",
      "visible_minorities",
      "geometry"
    )
  ) %>%
  mutate(housing_need = housing_need_rent + housing_need_own) %>%
  select(
    Geo_UID,
    PR_UID,
    CMA_UID,
    CMA_name,
    population,
    unemployed_pct,
    housing_need,
    med_income,
    visible_minorities,
    geometry
  ) %>%
  mutate_at(
    c(
      "housing_need",
      "visible_minorities"
    ),
    list(`pct` = ~ {
      . / population
    })
  )


### Import and process CMAs_2016 and service_areas_2016 ########################

CMAs_2016 <-
  get_census(
    dataset = 'CA16',
    regions = list(C = "Canada"),
    level = 'CMA',
    geo_format = "sf"
  ) %>%
  st_transform(3347) %>%
  filter(Type == "CMA") %>%
  select(GeoUID, CMA_name = name)

libraries_2016 <-
  libraries[lengths(st_within(libraries, CMAs_2016)) > 0,]

CMAs_2016 <-
  CMAs_2016[lengths(st_contains(CMAs_2016, libraries_2016)) > 0,] %>%
  mutate(CMA_name = ifelse(str_detect(CMA_name, "Mont"), "Montreal (B)",
                           CMA_name))

service_areas_2016 <- make_library_service_areas(libraries_2016, CMAs_2016)


### Import and process CTs_2016 ################################################

CTs_2016 <-
  get_census(
    dataset = "CA16",
    regions = list(C = "Canada"),
    level = "CT",
    vectors = c(
      "v_CA16_5618",
      "v_CA16_4888",
      "v_CA16_2398",
      "v_CA16_3957"
    ),
    geo_format = "sf"
  ) %>%
  st_transform(3347) %>%
  filter(Type == "CT") %>%
  select(GeoUID, PR_UID, CMA_UID, Population, contains("v_CA")) %>%
  inner_join(st_drop_geometry(CMAs_2016), by = c("CMA_UID" = "GeoUID")) %>%
  select(GeoUID, PR_UID, CMA_UID, CMA_name, everything()) %>%
  set_names(
    c(
      "Geo_UID",
      "PR_UID",
      "CMA_UID",
      "CMA_name",
      "population",
      "unemployed_pct",
      "housing_need",
      "med_income",
      "visible_minorities",
      "geometry"
    )
  ) %>%
  mutate_at(
    .vars = c(
      "housing_need",
      "visible_minorities"
    ),
    .funs = list(`pct` = ~ {
      . / population
    })
  )