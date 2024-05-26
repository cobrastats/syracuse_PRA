## P+R+A Table - Syracuse Orange
![cuse_pra](https://github.com/cobrastats/syracuse_PRA/assets/109628356/71d6360b-37fd-493f-bf8c-409fb85cbe91)
 
##### First install necessary packages. `cbbdata` is likely the only one not in CRAN, so if you don't have that you may need to first install it using `devtools`

```r
devtools::install_github("andreweatherman/cbbdata")
library(cbbdata)

#All from CRAN
library(glue)
library(dplyr)
library(gt)
library(gtExtras)
```

##### Using `cbbdata`, you can pull all player season stats back to 2008
```r
stats = cbd_torvik_player_season()
```

##### From here, we can do the bulk of our cleaning/organizing of the data. Lots of things going on, so all is noted within the code

```r
players = stats %>%                                                     
  filter(team=="Syracuse") %>%                                         #Filter for just players from Syracuse
  filter(g>=20) %>%                                                    #We want players that actually played, so set at at least 20 games played
  select(player,exp,g,ppg,rpg,apg,year) %>%                            #Select just the variables we are going to use
  mutate(pra = ppg + rpg + apg) %>%                                    #Create a pra variable, which just adds ppg, rpg, and apg
  arrange(desc(pra)) %>%                                               #Arrange in descending order to get the highest at the top
  slice_head(n=10) %>%                                                 #Slice head at 10 just to make a top-10 list
  mutate(rank = row_number(),years = paste0(year,"<br>",exp,".")) %>%  #Create variable for rank + combine year and experience with <br>
  select(rank,player,years,g,ppg,rpg,apg,pra)                          #Select only variables used in table + selected in order within the table
```

##### Now that we have our data, we can start piecing together our table, starting with the header. This is where we can include a team logo (note the imgur link within)
```r
title_header <- glue(
  "<div style='display: flex; justify-content: space-between; align-items: center;'>
     <div style='flex-grow: 1;'>
       <span style='font-family: Roboto, sans-serif; font-weight: bold; font-size: 24px; line-height: 0.6;'>Syracuse Orange - PRA Leaders</span><br>
       <span style='font-family: Roboto, sans-serif; font-size: 16px; font-weight: normal; line-height: 0.3;'>PPG + RPG + APG - since 2008</span>
     </div>
     <div>
       <img src='https://i.imgur.com/PVLqmTX.png' style='height: 70px; width: auto; vertical-align: right;'>
     </div>
   </div>"
)
```

##### So within the table, there's a lot going on to customize the table how we want. Instead of adding notation within the entire code block, I want to use this `README` to just explain why each step is being done. The complete code for the table (rather than broken into pieces) can be found in the repository as well.

###### Convert dataframe in gt object
```r
table = players %>% gt() %>% fmt_markdown() %>%
```
###### Add the table header created above
```r
  tab_header(title = html(title_header)) %>%
```
###### Assign theme from `gtExtras` package - I'm a big fan of the `gt_theme_538`
```r
  gt_theme_538() %>%
```
###### Some columns we want aligned center, some left. That's done here
```r
  cols_align(align = "center",columns = c("rank","years","g","ppg","rpg","apg","pra")) %>%
  cols_align(align = "left",columns = c("player")) %>%
```
###### Assign column widths to each column. I like customizing each one (though you have to play around with each). If you don't assign a width, it will auto-size it
```r
  cols_width(
    rank ~px(25),
    player ~px(150),
    years ~px(60),
    g ~px(45),
    ppg ~px(50),
    rpg ~px(50),
    apg ~px(50),
    pra ~px(60)) %>%
```
###### Assign each column a label. This is the label that will appear on your actual table. 
```r
  cols_label(
    rank = "",
    player="Player",
    years= "",
    g = "GP",
    ppg = "PTS",
    rpg = "REB",
    apg = "AST",
    pra = "P+R+A") %>%
```
###### Create a spanner to span the 3 'per game' columns. That way, rather than just putting PPG, RPG, and APG, we can says PTS, REB, and AST with the spanner telling everyone it's on a per game basis
```r
  tab_spanner(
    label = "PER GAME",
    columns = c("ppg","rpg","apg")) %>%
```
###### Some of our numbers came as long decimals. To clean things up we just want everything out to a single decimal point
```r
  fmt_number(
    columns = c("ppg","rpg","apg","pra"),
    decimals = 1) %>%
```
##### Everything from here will be less about the data and more about the table style - or just the way we want our table to look

###### First we want to stylize a few of the columns. We want our PRA column to be bolded (since it's the primary focus) and make the rank, years, and games played columns slightly smaller because they're not the main focus (I'd almost say they are tertiary with name, ppg, rpg, apg being secondary)
 ```r 
  tab_style(
    style = cell_text(weight="bold"),
    locations = cells_body(
      rows = everything(),
      columns = c("pra")
    )) %>%
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
      columns = c(1,3,4)
    )) %>%
```

###### Like I did in the title header, I want to change the font to the Google font `Roboto` just to give it a different look. But I want this to apply teh whole table as well as the column headers + spanners. I ignore columns 1, 3, and 4 because we already added some formatting to those
```r 
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
```

###### Since Judah Mintz's 2024 season shows up in this list, let's make sure we draw attention to that. What I typically do is take the team's color (in this case, Syracuse Orange), and take that hex code to a tint converter website. I'll then take one or two shades from white. Doesn't take much for the color to pop on white, plus you still want to be able to see the text. Some people prefer much darker tints and then convert text to white. I prefer lighter shades of highlighting
```r  
  tab_style(
    style = cell_fill(color = "#fde1cc"),
    locations = cells_body(
      rows = 6,
      columns = everything()
    )) %>% 
```
###### Add row padding - which is essentially just to make your rows slightly taller to make things not look as cluttered
```r
  tab_options(data_row.padding = px(4)) %>% 
```

###### Add your own notation at the bottom and add any formatting
```r
  tab_source_note(md("Analysis by @cobrastats | Data via cbbdata | May 26, 2024")) %>%
  tab_style(
    style = cell_text(size = px(10)),
    locations = cells_source_notes()) %>% 
```

###### Finally, export as .png to your preferred path. I also will typically expand my edges a bit (especially left and right). But I'll go to extremes at time if needed so that it looks good on Twitter/X. Also, adding a zoom gives it a higher resolution. Especially good if you're working with team logos or player images
``` 
  gtsave("/cuse_pra.png", expand = c(10,30,10,30),zoom=4)
