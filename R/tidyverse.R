# Examples of using tidyverse functions

# Imports --------------------------------------------------------------------

library(here)
library(tidyverse)

# Reading and printing -------------------------------------------------------

# Read in the voting summary dataset
vs <- read_csv(here("data", "ge2019-voting-summary.csv"))

# Using the pipe to print: the two uses of print are equivalent
print(vs, n = 20)
vs |> print(n = 20)

# select ----------------------------------------------------------------------

# Using select to get the constituency name and the winning party
lead_parties <- select(vs, constituency_name, first_party, second_party)

lead_parties <- vs |> 
    select(constituency_name, first_party, second_party)

# filter ----------------------------------------------------------------------

# Using filter to get all constituencies where Labour came first
lab_seats <- vs |> 
    filter(first_party == "Lab")

# Using filter to get all constituencies where Labour didn't come first
not_lab_seats <- vs |> 
  filter(first_party != "Lab")

# Using filter to get all Labour seats with a majority of 10,000 or more
safe_lab_seats <- vs |> 
    filter(first_party == "Lab", majority >= 10000)

# Using filter to get all Labour and SNP seats
lab_snp_seats <- vs |> 
    filter(first_party == "Lab" | first_party == "SNP")

# You could also do it like this
lab_snp_seats <- vs |> 
    filter(first_party %in% c("Lab", "SNP"))

# Using filter and select to summarise safe Labour seats
safe_lab_summary <- vs |> 
    filter(first_party == "Lab", majority >= 10000) |>
    select(constituency_name, majority)

# arrange ---------------------------------------------------------------------

# Using arrange to sort the rows by region name and constituency name
sorted_results <- vs |> 
    arrange(region_name, constituency_name)

sorted_results <- vs |> 
    arrange(desc(region_name), constituency_name)

# Using filter, select and arrange to summarise safe Labour seats
safe_lab_summary <- vs |> 
    filter(first_party == "Lab", majority >= 10000) |>
    select(constituency_name, majority) |> 
    arrange(desc(majority))

# mutate ----------------------------------------------------------------------

# Use mutate to add a turnout column
vs <- vs |> 
  mutate(turnout = valid_votes / electorate)

vs |> select(constituency_name, turnout)

vs <- vs |> 
  mutate(
    con_share = con / valid_votes,
    lab_share = lab / valid_votes)

vs |> select(
  constituency_name, 
  con_share, 
  lab_share)

# summarise -------------------------------------------------------------------

# Using summarise to summarise a data frame
mean_con_share <- vs |> 
    summarise(mean = mean(con_share))

median_con_share <- vs |> 
    summarise(median = median(con_share))

average_con_share <- vs |> 
    summarise(mean = mean(con_share),
              median = median(con_share))

# group_by --------------------------------------------------------------------

# Using group_by and summarise to summarise a data frame by group
mean_con_share_region <- vs |> 
    group_by(region_name) |> 
    summarise(mean = mean(con_share))

mean_con_share_region_type <- vs |> 
    group_by(region_name, constituency_type) |> 
    summarise(mean = mean(con_share))

count_constituencies_region_type <- vs |> 
    group_by(region_name, constituency_type) |> 
    summarise(count = n())

# left_join ------------------------------------------------------------------

# Read in the winning candidates dataset
wc <- read_csv(here("data", "ge2019-winning-candidates.csv"))

# Select the relevant columns from winning candidates
wc <- wc |> select(ons_id, firstname, surname)

# Use left_join to add winning candidates to the summary results
vs_wc <- left_join(vs, wc, by = "ons_id")

# Get the MPs' majorities
mps_majority <- vs_wc |> 
    select(firstname, surname, majority) |> 
    arrange(surname)

# pivot_longer ---------------------------------------------------------------

# Select just the columns showing the votes by party in each constituency.
# Here we use the minus sign to drop columsn we don't want.
votes <- vs |> 
  select(
    constituency_name,
    con,
    lab,
    ld,
    brexit,
    green,
    snp,
    pc,
    dup,
    sf,
    sdlp,
    uup,
    alliance)

# Pivot the data into long format excluding constituency_name from the pivot
votes_long <- pivot_longer(
    votes, 
    cols = -constituency_name,
    names_to = "party",
    values_to = "votes")

# pivot_wider ----------------------------------------------------------------

votes_wide <- pivot_wider(
    votes_long,
    id_cols = constituency_name,
    names_from = "party",
    values_from = "votes")
