devtools::install_github("andreweatherman/cbbdata")
library(cbbdata)

library(glue)
library(dplyr)
library(gt)
library(gtExtras)

stats = cbd_torvik_player_season()

players = stats %>% 
  filter(team=="Syracuse") %>% 
  filter(g>=20) %>% 
  select(player,exp,g,ppg,rpg,apg,year) %>% 
  mutate(pra = ppg + rpg + apg) %>% 
  arrange(desc(pra)) %>% 
  slice_head(n=10) %>% 
  mutate(rank = row_number(),years = paste0(year,"<br>",exp,".")) %>% 
  select(rank,player,years,g,ppg,rpg,apg,pra)

title_header <- glue(
  "<div style='display: flex; justify-content: space-between; align-items: center;'>
     <div style='flex-grow: 1;'>
       <span style='font-family: Roboto, sans-serif; font-weight: bold; font-size: 24px; line-height: 0.6;'>Syracuse Orange - PRA Leaders</span><br>
       <span style='font-family: Roboto, sans-serif; font-size: 16px; font-weight: normal; line-height: 0.3;'>PPG + RPG + APG - since 2008</span>
     </div>
     <div>
       <img src='https://i.imgur.com/PVLqmTX.png' style='height: 70px; width: auto; vertical-align: right;'>
     </div>
   </div>")

table = players %>% gt() %>% fmt_markdown() %>% 
  tab_header(title = html(title_header)) %>%
  gt_theme_538() %>%
  cols_align(align = "center",columns = c("rank","years","g","ppg","rpg","apg","pra")) %>%
  cols_align(align = "left",columns = c("player")) %>%
  cols_width(
    rank ~px(25),
    player ~px(150),
    years ~px(60),
    g ~px(45),
    ppg ~px(50),
    rpg ~px(50),
    apg ~px(50),
    pra ~px(60)) %>%
  cols_label(
    rank = "",
    player="Player",
    years= "",
    g = "GP",
    ppg = "PTS",
    rpg = "REB",
    apg = "AST",
    pra = "P+R+A") %>%
  tab_spanner(
    label = "PER GAME",
    columns = c("ppg","rpg","apg")) %>%
  fmt_number(
    columns = c("ppg","rpg","apg","pra"),
    decimals = 1) %>%
  tab_style(
    style = cell_text(weight="bold"),
    locations = cells_body(
      rows = everything(),
      columns = c("pra"))) %>%
  tab_style(
    style = cell_text(weight="bold"),
    locations = cells_column_labels(
      columns = c("pra"))) %>% 
  tab_style(
    style = cell_text(size = px(12)),
    locations = cells_column_labels(
      columns = c("g"))) %>% 
  tab_style(
    style = cell_text(size = px(12), weight = "normal", color = "#333333"),
    locations = cells_body(
      rows = everything(),
      columns = c(1,3,4))) %>%
  opt_table_font(
    font = list(
      google_font(name = "Roboto"))) %>% 
  tab_style(
    style = cell_text(size = px(14),color = "black",weight = "normal",
                      font = google_font(name = "Roboto")),
    locations = cells_column_labels(-c(1,3,4))) %>% 
  tab_style(
    style = cell_text(size = px(14), font = google_font(name = "Roboto")),
    locations = cells_column_spanners(
      spanners = "PER GAME")) %>% 
  tab_style(
    style = cell_fill(color = "#fde1cc"),
    locations = cells_body(
      rows = 6,
      columns = everything())) %>% 
  tab_options(data_row.padding = px(4)) %>% 
  tab_source_note(md("Analysis by @cobrastats | Data via cbbdata | May 26, 2024")) %>%
  tab_style(
    style = cell_text(size = px(10)),
    locations = cells_source_notes()) %>% 
  gtsave("/Users/connorbradley/Desktop/basketball data/cuse_pra.png", expand = c(10,30,10,30),zoom=4)