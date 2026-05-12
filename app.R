library(shiny)
library(plotly)
library(sf)
library(dplyr)
library(tidyr)
library(geojsonsf)
library(rnaturalearth)

# K??resel ge??erlilik hatalar??n?? ??nlemek i??in S2 kapat??ld??
sf::sf_use_s2(FALSE)

## ---------------------------
## 1. Helper: Load World Geometry
## ---------------------------
load_world_geometry <- function() {
  g <- rnaturalearth::ne_countries(scale = "small", returnclass = "sf") %>%
    st_make_valid() %>%
    st_transform(4326) %>%
    select(iso_a3, admin, geometry) %>%
    rename(name = admin) %>%
    filter(!is.na(iso_a3), iso_a3 != "")
  
  g <- g %>%
    st_simplify(dTolerance = 0.08, preserveTopology = TRUE) %>%
    st_make_valid()
  return(g)
}

## ---------------------------
## 2. Helper: Load Real Temperature Data
## ---------------------------
load_temperature_data <- function(csv_path = "GlobalWeatherRepository.csv") {
  weather_data <- read.csv(csv_path, stringsAsFactors = FALSE)
  
  country_temps <- weather_data %>%
    group_by(country) %>%
    summarize(avg_temp = mean(temperature_celsius, na.rm = TRUE)) %>%
    ungroup()
  
  country_temps <- country_temps %>%
    mutate(country = case_when(
      country %in% c("USA United States of America", "United States of America") ~ "United States of America",
      country == "United Kingdom" ~ "United Kingdom",
      TRUE ~ country
    ))
  return(as.data.frame(country_temps))
}

## ---------------------------
## 3. UI
## ---------------------------
ui <- fluidPage(
  tags$head(
    tags$title("Global Temperature Globe Dashboard"),
    tags$style(HTML("
      :root {
        --bg: #0b1220;
        --card: rgba(255,255,255,0.06);
        --text: rgba(255,255,255,0.92);
        --muted: rgba(255,255,255,0.70);
        --border: rgba(255,255,255,0.12);
        --accent-2: #7ef0b3;
      }
      body {
        background: radial-gradient(1200px 700px at 20% 0%, rgba(122,162,255,0.18), transparent 60%), var(--bg);
        color: var(--text);
        font-family: sans-serif;
      }
      .card { background: var(--card); border: 1px solid var(--border); border-radius: 14px; padding: 14px; box-shadow: 0 12px 30px rgba(0,0,0,0.25); margin-bottom: 20px; }
      .grid { display: grid; grid-template-columns: 1.4fr 1fr; gap: 14px; padding: 20px; }
      .btn-custom { background: rgba(122,162,255,0.20); border: 1px solid rgba(122,162,255,0.40); color: white; border-radius: 12px; padding: 8px 12px; }
    "))
  ),
  
  div(style="padding: 20px 20px 0 20px;",
      h1("Global Temperature Globe Dashboard"),
      p("Interactive 3D globe with real country-level temperature data.")
  ),
  
  div(class = "grid",
      div(class = "card",
          h3("3D Globe Heatmap"),
          div(style = "display:flex; gap:10px; align-items:center; margin-bottom: 10px;",
              selectInput("globe_dragmode", NULL, choices = c("Rotate" = "rotate", "Pan" = "pan", "Zoom" = "zoom"), width = "150px"),
              actionButton("clear_pin", "Clear selection", class = "btn-custom")
          ),
          plotlyOutput("globe", height = "660px")
      ),
      
      div(class = "card",
          h3("Selection & 2D Analytics"),
          uiOutput("selection_panel"), 
          hr(style = "border-top:1px solid var(--border);"),
          div(class = "small muted", "Top 5 Hottest & Coldest countries:"),
          plotlyOutput("top5_plot", height = "360px"),
          hr(style = "border-top:1px solid var(--border);"),
          div(class = "small muted", "Temperature distribution histogram:"),
          plotlyOutput("hist_plot", height = "320px")
      )
  )
)

## ---------------------------
## 4. Server Logic
## ---------------------------
server <- function(input, output, session) {
  
  deg <- "\u00b0C" # Unicode degree symbol
  
  # Hex Codes to prevent "unknown colour name" errors
  color_hot <- "#B22222" # Dark Red
  color_cold <- "#003F8E" # Deep Blue
  
  data_pack <- reactive({
    world_sf <- load_world_geometry()
    temps_df <- load_temperature_data("GlobalWeatherRepository.csv")
    
    joined <- world_sf %>%
      left_join(temps_df, by = c("name" = "country")) %>%
      mutate(avg_temp = as.numeric(avg_temp))
    return(joined)
  })
  
  selected_iso <- reactiveVal(NULL)
  
  observeEvent(event_data("plotly_click", source = "globe"), {
    ev <- event_data("plotly_click", source = "globe")
    if (!is.null(ev)) selected_iso(as.character(ev$location))
  })
  
  observeEvent(input$clear_pin, { selected_iso(NULL) })
  
  # --- Globe Render ---
  output$globe <- renderPlotly({
    df <- data_pack()
    
    plot_geo(source = "globe") %>%
      add_trace(
        type = "choropleth",
        locations = df$iso_a3,
        locationmode = "ISO-3",
        z = df$avg_temp,
        text = df$name,
        hovertemplate = paste0("<b>%{text}</b><br>Temp: %{z:.1f} ", deg, "<extra></extra>"),
        colorscale = list(list(0, color_cold), list(0.5, "#F5F5F5"), list(1, color_hot)),
        showscale = TRUE
      ) %>%
      layout(
        geo = list(
          projection = list(type = "orthographic"),
          showocean = TRUE, oceancolor = "rgba(147, 197, 253, 0.40)",
          showland = TRUE, landcolor = "rgba(255,255,255,0.14)",
          bgcolor = "rgba(0,0,0,0)"
        ),
        paper_bgcolor = "rgba(0,0,0,0)",
        margin = list(l=0, r=0, t=0, b=0)
      )
  })
  
  # --- Selection Panel ---
  output$selection_panel <- renderUI({
    df <- data_pack() %>% st_drop_geometry()
    sel <- selected_iso()
    
    if (is.null(sel)) return(div(style="color:rgba(255,255,255,0.5);", "Click a country on the globe."))
    
    row <- df %>% filter(iso_a3 == sel) %>% slice(1)
    
    tagList(
      h4(as.character(row$name), style="color:white; margin-top:10px;"),
      div(style="font-size:28px; color: var(--accent-2); font-weight:bold;", 
          paste0(round(row$avg_temp, 1), " ", deg))
    )
  })
  
  # --- Grouped Bar Chart (Hottest & Coldest) ---
  output$top5_plot <- renderPlotly({
    df <- data_pack() %>% st_drop_geometry() %>% filter(!is.na(avg_temp))
    
    hot <- df %>% arrange(desc(avg_temp)) %>% head(5) %>% mutate(Category = "Hottest")
    cold <- df %>% arrange(avg_temp) %>% head(5) %>% mutate(Category = "Coldest")
    extremes <- bind_rows(hot, cold)
    
    plot_ly(extremes, 
            x = ~name, 
            y = ~avg_temp, 
            color = ~Category, 
            type = "bar", 
            colors = c("Hottest" = color_hot, "Coldest" = color_cold),
            hovertemplate = paste0("<b>%{text}</b><br>Temp: %{y:.1f}", deg, "<extra></extra>"),
            text = ~name) %>%
      layout(
        barmode = "group",
        paper_bgcolor = "rgba(0,0,0,0)", 
        plot_bgcolor = "rgba(0,0,0,0)", 
        font = list(color="white"),
        xaxis = list(title = "Country", tickangle = -45), 
        yaxis = list(title = paste0("Temperature (", deg, ")")),
        legend = list(orientation = 'h', x = 0.5, xanchor = 'center', y = 1.1)
      )
  })
  
  # --- Histogram ---
  output$hist_plot <- renderPlotly({
    df <- data_pack() %>% st_drop_geometry() %>% filter(!is.na(avg_temp))
    plot_ly(df, x = ~avg_temp, type = "histogram", marker = list(color = "rgba(122,162,255,0.5)")) %>%
      layout(paper_bgcolor = "rgba(0,0,0,0)", plot_bgcolor = "rgba(0,0,0,0)", font = list(color="white"),
             xaxis = list(title = paste0("Temp Range (", deg, ")")), yaxis = list(title = "Count"))
  })
}

shinyApp(ui = ui, server = server)