# ---- Libraries ----
library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(plotly)
library(leaflet)
library(DT)
library(dplyr)
library(tidyr)
library(lubridate)
library(stringr)
library(scales)
library(RColorBrewer)

# ---- Load Cleaned Data ----
data <- read.csv("236055B-cleaned_terroristdataset.csv", stringsAsFactors = FALSE)

# Ensure proper types
data$date <- as.Date(data$date)
data$impact_level <- factor(data$impact_level, levels = c("Low", "Medium", "High"), ordered = TRUE)

# ---- UI ----
ui <- dashboardPage(
  dashboardHeader(title = "Terrorism Dashboard"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Incident Analysis", tabName = "incidents", icon = icon("map")),
      menuItem("Casualties & Human Impact", tabName = "casualties", icon = icon("heartbeat")),
      menuItem("Perpetrator & Target Analysis", tabName = "perpetrator", icon = icon("users")),
      menuItem("Trend & Comparative Analysis", tabName = "trend", icon = icon("chart-line")),
      hr(),
      pickerInput(
        "region", 
        "Select Region:", 
        choices = unique(data$region), 
        multiple = TRUE, 
        options = list(`actions-box` = TRUE)
      ),
      uiOutput("country_filter"),
      sliderInput(
        "year_range", 
        "Year Range:", 
        min = min(data$year), 
        max = max(data$year),
        value = c(min(data$year), max(data$year)), 
        step = 1, 
        sep = ""
      ),
      pickerInput(
        "attack_type", 
        "Attack Type:", 
        choices = unique(data$attacktype1_txt), 
        multiple = TRUE, 
        options = list(`actions-box` = TRUE)
      ),
      sliderInput(
        "casualty_range", 
        "Casualty Range:", 
        min = 0, 
        max = max(data$total_casualties, na.rm = TRUE),
        value = c(0, max(data$total_casualties, na.rm = TRUE))
      ),
      checkboxGroupInput(
        "impact_filter", 
        "Impact Level:", 
        choices = levels(data$impact_level), 
        selected = levels(data$impact_level)
      )
    )
  ),
  
  dashboardBody(
    tabItems(
      
      # ---- Page 1: Incident Analysis ----
      tabItem(
        tabName = "incidents",
        fluidRow(
          valueBoxOutput("total_incidents"),
          valueBoxOutput("avg_casualties"),
          valueBoxOutput("high_impact_pct")
        ),
        fluidRow(
          box(width = 6, plotlyOutput("top_countries")),
          box(width = 6, plotlyOutput("attack_type_pie")),
          box(width = 12, plotlyOutput("country_attack_drill"))
          
        ),
        fluidRow(
          box(
            title = tags$span(
              "Incident Map: Attack Locations & Casualties",
              style = "text-align:center;color:#2C3E50; font-weight:bold; font-size:18px;"
            ),
            width = 12,
            leafletOutput("incident_map", height = 500)
          )
        )
      ),
      
      # ---- Page 2: Casualties ----
      tabItem(
        tabName = "casualties",
        
        fluidRow(
          box(width = 12, plotlyOutput("killed_vs_wounded"))
        ),
        
        fluidRow(
          box(width = 6, plotlyOutput("casualties_by_attack")),
          box(width = 6, plotlyOutput("casualties_heatmap"))
        ),
        
        fluidRow(
          box(
            width = 12,
            fluidRow(
              column(width = 8, plotlyOutput("casualties_box_weapon")),
              column(width = 4, DTOutput("weapon_code_map"))
            )
          )
        ),
        
        fluidRow(
          box(width = 12, plotlyOutput("casualties_region_comparison"))
        )
      ),
      # ---- Page 3: Perpetrator & Target ----
      tabItem(
        tabName = "perpetrator",
        fluidRow(
          box(width = 6, plotlyOutput("top_groups")),
          box(width = 6, plotlyOutput("target_type_stack"))
        ),
        fluidRow(
          column(
            12,
            tags$h3(
              "Group vs Target Map (Colored by Impact Level)",
              style = "text-align:center; font-weight:bold; color:#2C3E50; margin-bottom:15px;"
            ),
            leafletOutput("group_target_map", height = 500)
          )
        ),
        fluidRow(
          box(width = 12, dataTableOutput("group_details"))
        )
      ),
      
      # ---- Page 4: Trend ----
      tabItem(
        tabName = "trend",
        fluidRow(
          box(width = 6, plotlyOutput("monthly_trend")),
          box(width = 6, plotlyOutput("stacked_region_trend"))
        ),
        fluidRow(
          box(width = 12, plotlyOutput("country_comparison"))
        )
      )
    )
  )
)

# ---- SERVER ----
server <- function(input, output, session) {
  
  
  # Dynamic country filter based on region
  output$country_filter <- renderUI({
    req(input$region)
    pickerInput(
      "country", 
      "Select Country:", 
      choices = unique(data$country[data$region %in% input$region]), 
      multiple = TRUE, 
      options = list(`actions-box` = TRUE)
    )
  })
  
  # Filtered dataset based on all filters
  filtered_data <- reactive({
    d <- data %>%
      filter(
        region %in% input$region | is.null(input$region),
        between(year, input$year_range[1], input$year_range[2]),
        total_casualties >= input$casualty_range[1],
        total_casualties <= input$casualty_range[2],
        impact_level %in% input$impact_filter
      )
    
    if (!is.null(input$country)) d <- d %>% filter(country %in% input$country)
    if (!is.null(input$attack_type)) d <- d %>% filter(attacktype1_txt %in% input$attack_type)
    d
  })
  # Reactive value with default
  selected_country <- reactiveVal(NULL)
  # --- Set default selected country ---
  observe({
    if (is.null(selected_country())) {
      top_country <- filtered_data() %>%
        count(country, sort = TRUE) %>%
        slice_max(n, n = 1) %>%
        pull(country)
      selected_country(top_country)
    }
  })
  # ---- KPIs ----
  output$total_incidents <- renderValueBox({
    valueBox(nrow(filtered_data()), "Total Incidents", icon = icon("bomb"), color = "red")
  })
  
  output$avg_casualties <- renderValueBox({
    valueBox(
      round(mean(filtered_data()$total_casualties, na.rm = TRUE), 2),
      "Avg Casualties",
      icon = icon("heartbeat"),
      color = "yellow"
    )
  })
  
  output$high_impact_pct <- renderValueBox({
    high_pct <- mean(filtered_data()$impact_level == "High") * 100
    valueBox(paste0(round(high_pct, 2), "%"), "High Impact Attacks", icon = icon("fire"), color = "purple")
  })
  
  # ---- Incident Analysis Plots ----
  output$top_countries <- renderPlotly({
    top_countries <- filtered_data() %>% count(country, sort = TRUE) %>% top_n(10)
    
    plot_ly(
      top_countries, 
      x = ~reorder(country, n), 
      y = ~n, 
      type = "bar",
      marker = list(color = ~RColorBrewer::brewer.pal(nrow(top_countries), "Dark2")),
      text = ~n, 
      textposition = "auto",
      source = "top_countries"   # <-- Set source for event_data
    ) %>%
      layout(
        title = "Top Countries by Incidents",
        xaxis = list(title = "Country"),
        yaxis = list(title = "Incidents")
      )
  })
  observeEvent(event_data("plotly_click", source = "top_countries"), {
    clicked <- event_data("plotly_click", source = "top_countries")$x
    selected_country(clicked)
  })
  
  # ---- Drill-down plot for attack types in selected country ----
  output$country_attack_drill <- renderPlotly({
    req(selected_country())
    
    df <- filtered_data() %>% filter(country == selected_country())
    attack_count <- df %>% count(attacktype1_txt)
    
    plot_ly(
      attack_count,
      x = ~attacktype1_txt,
      y = ~n,
      type = 'bar',
      marker = list(color = brewer.pal(max(3, nrow(attack_count)), "Set2"))
    ) %>%
      layout(
        title = paste("Attack Types in", selected_country()),
        xaxis = list(title = "Attack Type"),
        yaxis = list(title = "Number of Incidents"),
        margin = list(l = 50, r = 50)
      )
  })
  
  
  
  output$attack_type_pie <- renderPlotly({
    attack_types <- filtered_data() %>% count(attacktype1_txt)
    
    plot_ly(
      attack_types,
      labels = ~attacktype1_txt,
      values = ~n,
      type = 'pie',
      textposition = 'inside',
      textinfo = 'label+percent',
      marker = list(colors = brewer.pal(max(3, nrow(attack_types)), "Dark2"))
    ) %>%
      layout(
        title = list(
          text = "Distribution of Attacks by Type",
          x = 0.5,
          xanchor = 'center',
          font = list(size = 16)
        )
      )
  })
  
  output$incident_map <- renderLeaflet({
    leaflet(filtered_data()) %>%
      addTiles() %>%
      addMarkers(
        ~longitude, ~latitude,
        popup = ~paste(country, "<br>", attacktype1_txt, "<br>", total_casualties, "casualties"),
        clusterOptions = markerClusterOptions()
      )
  })
  
  # ---- Casualties ----
  output$killed_vs_wounded <- renderPlotly({
    time_series <- filtered_data() %>% group_by(year) %>% summarise(kills = sum(kills), wounded = sum(wounded))
    plot_ly(time_series, x = ~year) %>%
      add_lines(y = ~kills, name = 'Kills', line = list(color = 'red')) %>%
      add_lines(y = ~wounded, name = 'Wounded', line = list(color = 'blue')) %>%
      layout(title = "Killed vs Wounded Over Time")
  })
  
  output$casualties_by_attack <- renderPlotly({
    attack_casualties <- filtered_data() %>%
      group_by(attacktype1_txt) %>%
      summarise(total = sum(total_casualties))
    
    plot_ly(
      attack_casualties,
      x = ~attacktype1_txt,
      y = ~total,
      type = 'bar',
      marker = list(color = brewer.pal(nrow(attack_casualties), "Dark2"))
    ) %>%
      layout(title = "Casualties by Attack Type")
  })
  output$casualties_heatmap <- renderPlotly({
    fd <- filtered_data()
    req(nrow(fd) > 0)
    heatmap_data <- fd %>%
      group_by(year, region) %>%
      summarise(total = sum(total_casualties, na.rm = TRUE), .groups = "drop")
    
    
    hm <- tidyr::pivot_wider(heatmap_data, names_from = year, values_from = total, values_fill = 0)
    
    
    plot_ly(
      x = names(hm)[-1],
      y = hm[[1]],
      z = as.matrix(hm[,-1]),
      type = "heatmap",
      colorscale = list(c(0,1), c("white","orange"))
    ) %>%
      layout(
        title = "Heatmap of Casualties by Region & Year",
        xaxis = list(title = "Year"),
        yaxis = list(title = "Region")
      )
  })
  output$casualties_box_weapon <- renderPlotly({
    fd <- filtered_data()
    req(nrow(fd) > 0)
    
    data_w <- fd %>% mutate(weapon1 = ifelse(is.na(weapon1), "Unknown", weapon1))
    
    weapon_types <- unique(data_w$weapon1)
    codes <- LETTERS[1:length(weapon_types)]
    weapon_map <- setNames(codes, weapon_types)
    data_w$weapon_code <- weapon_map[data_w$weapon1]
    
    # Use darkest contrasting palette
    max_colors <- max(3, min(9, length(weapon_types)))  # Set1 supports up to 9
    palette <- RColorBrewer::brewer.pal(max_colors, "Set1")
    
    plot_ly(
      data_w,
      x = ~weapon_code,
      y = ~total_casualties,
      type = 'box',
      color = ~weapon_code,
      colors = palette
    ) %>%
      layout(
        title = list(
          text = "Casualties by Weapon Type (Boxplot)",
          font = list(size = 18, face = "bold")
        ),
        xaxis = list(title = "Weapon Code"),
        yaxis = list(title = "Total Casualties")
      )
  })
  
  output$weapon_code_map <- renderDT({
    fd <- filtered_data()
    req(nrow(fd) >= 0) # allow zero rows but still show mapping
    
    weapon_types <- unique(ifelse(is.na(fd$weapon1), "Unknown", fd$weapon1))
    codes <- LETTERS[1:length(weapon_types)]
    mapping_df <- data.frame(Code = codes, Weapon_Type = weapon_types, stringsAsFactors = FALSE)
    
    datatable(mapping_df, options = list(dom = 't', paging = FALSE), rownames = FALSE)
  })
  
  
  
  
  output$casualties_region_comparison <- renderPlotly({
    comp <- filtered_data() %>% group_by(region) %>% summarise(total = sum(total_casualties), avg = mean(total_casualties))
    plot_ly(comp, x = ~region, y = ~total, type = 'bar', name = 'Total', marker = list(color = 'darkblue')) %>%
      add_trace(y = ~avg, name = 'Avg', marker = list(color = 'darkorange')) %>%
      layout(title = "Total vs Avg Casualties by Region", barmode = 'group')
  })
  
  # ---- Perpetrator ----
  output$top_groups <- renderPlotly({
    top_groups <- filtered_data() %>% count(perpetrator_group, sort = TRUE) %>% top_n(10)
    plot_ly(
      top_groups, x = ~reorder(perpetrator_group, n), y = ~n, type = 'bar',
      marker = list(color = brewer.pal(nrow(top_groups), "Dark2"))
    ) %>%
      layout(title = "Top Perpetrator Groups", xaxis = list(tickfont = list(size = 12, weight = 'bold')))
  })
  
  output$target_type_stack <- renderPlotly({
    targ <- filtered_data() %>% count(target_type)
    plot_ly(
      targ,
      labels = ~target_type,
      values = ~n,
      type = 'pie',
      marker = list(colors = brewer.pal(max(3, nrow(targ)), "Dark2"))
    ) %>%
      layout(
        title = list(
          text = "Target Types Distribution",
          x = 0.5,
          xanchor = 'center',
          font = list(size = 18, color = '#2C3E50', family = "Arial")
        )
      )
  })
  
  output$group_target_map <- renderLeaflet({
    leaflet(filtered_data()) %>%
      addTiles() %>%
      addCircleMarkers(
        ~longitude, ~latitude,
        popup = ~paste(perpetrator_group, "->", target_type),
        color = ~ifelse(impact_level == "High", "red", ifelse(impact_level == "Medium", "orange", "green")),
        radius = 5,
        fillOpacity = 0.7,
        clusterOptions = markerClusterOptions()
      )
  })
  
  output$group_details <- renderDataTable({
    filtered_data() %>% 
      group_by(perpetrator_group) %>% 
      summarise(Incidents = n(), Total_Casualties = sum(total_casualties)) %>% 
      arrange(desc(Incidents))
  })
  
  # ---- Trend ----
  output$monthly_trend <- renderPlotly({
    trend <- filtered_data() %>% group_by(year, month) %>% summarise(n = n())
    plot_ly(trend, x = ~paste(year, month, sep = "-"), y = ~n, type = 'scatter', mode = 'lines+markers', line = list(color = 'darkgreen')) %>%
      layout(title = "Monthly Incident Trend")
  })
  
  output$stacked_region_trend <- renderPlotly({
    reg_trend <- filtered_data() %>% group_by(year, region) %>% summarise(n = n())
    plot_ly(reg_trend, x = ~year, y = ~n, color = ~region, type = 'scatter', mode = 'lines', stackgroup = 'one') %>%
      layout(title = "Stacked Region Trend")
  })
  
  output$country_comparison <- renderPlotly({
    comp <- filtered_data() %>% group_by(country) %>% summarise(n = n(), casualties = sum(total_casualties)) %>% top_n(5, n)
    plot_ly(comp, x = ~country, y = ~n, type = 'bar', name = 'Incidents', marker = list(color = 'darkblue')) %>%
      add_trace(y = ~casualties, name = 'Casualties', marker = list(color = 'darkred')) %>%
      layout(title = "Top 5 Country Comparison (Incidents vs Casualties)", barmode = 'group', xaxis = list(tickfont = list(size = 12, weight = 'bold')))
  })
}

# ---- Run App ----
shinyApp(ui, server)

