# MALDIquant Windows Application
# Main Shiny Application File

library(shiny)
library(MALDIquant)
library(MALDIquantForeign)
library(plotly)
library(DT)

# Optional packages
USE_COLOURPICKER <- requireNamespace("colourpicker", quietly = TRUE)
if (USE_COLOURPICKER) {
  library(colourpicker)
}

# UI Definition
ui <- fluidPage(
  titlePanel(
    div(
      img(src = "logo.png", height = 50, style = "display: inline-block; margin-right: 10px;"),
      "MALDIquant Analyzer",
      style = "display: flex; align-items: center;"
    )
  ),

  theme = bslib::bs_theme(version = 4, bootswatch = "flatly"),

  sidebarLayout(
    sidebarPanel(
      width = 3,

      h4("Data Import"),
      fileInput("dataFiles", "Select Spectra Files",
                multiple = TRUE,
                accept = c(".mzML", ".mzXML", ".txt", ".csv")),

      hr(),

      h4("Preprocessing"),
      checkboxInput("doSmoothing", "Apply Smoothing", value = TRUE),
      conditionalPanel(
        condition = "input.doSmoothing == true",
        selectInput("smoothMethod", "Smoothing Method:",
                    choices = c("SavitzkyGolay", "MovingAverage"),
                    selected = "SavitzkyGolay"),
        numericInput("halfWindowSize", "Half Window Size:", value = 10, min = 1, max = 50)
      ),

      checkboxInput("doBaseline", "Remove Baseline", value = TRUE),
      conditionalPanel(
        condition = "input.doBaseline == true",
        selectInput("baselineMethod", "Baseline Method:",
                    choices = c("SNIP", "TopHat", "ConvexHull", "median"),
                    selected = "SNIP")
      ),

      hr(),

      h4("Peak Detection"),
      numericInput("snr", "Signal-to-Noise Ratio (SNR):", value = 3, min = 1, max = 20),
      numericInput("halfWindowSizePeak", "Half Window Size:", value = 20, min = 1, max = 100),

      hr(),

      actionButton("processBtn", "Process Data",
                   class = "btn-primary btn-lg btn-block",
                   icon = icon("play")),

      hr(),

      downloadButton("downloadResults", "Download Results", class = "btn-success btn-block"),
      downloadButton("downloadPlot", "Download Plot", class = "btn-info btn-block")
    ),

    mainPanel(
      width = 9,

      tabsetPanel(
        id = "mainTabs",
        type = "tabs",

        tabPanel("Overview",
                 icon = icon("info-circle"),
                 br(),
                 h3("Welcome to MALDIquant Analyzer"),
                 p("This application provides a user-friendly interface for mass spectrometry data analysis using MALDIquant."),

                 h4("Workflow:"),
                 tags$ol(
                   tags$li("Import your spectra files (mzML, mzXML, or text formats)"),
                   tags$li("Configure preprocessing options (smoothing, baseline correction)"),
                   tags$li("Set peak detection parameters"),
                   tags$li("Click 'Process Data' to analyze"),
                   tags$li("View results in the Spectra and Peaks tabs"),
                   tags$li("Download results and plots")
                 ),

                 h4("Supported Formats:"),
                 tags$ul(
                   tags$li("mzML"),
                   tags$li("mzXML"),
                   tags$li("Bruker flex files"),
                   tags$li("CSV/TXT (tab-separated: mass, intensity)")
                 ),

                 hr(),

                 h4("Current Status:"),
                 verbatimTextOutput("statusInfo")
        ),

        tabPanel("Spectra",
                 icon = icon("chart-line"),
                 br(),
                 fluidRow(
                   column(12,
                          h4("Spectrum Visualization"),
                          plotlyOutput("spectraPlot", height = "600px")
                   )
                 ),
                 br(),
                 fluidRow(
                   column(6,
                          numericInput("spectrumIndex", "Select Spectrum Index:",
                                       value = 1, min = 1, max = 1)
                   ),
                   column(6,
                          checkboxInput("showPeaks", "Show Detected Peaks", value = TRUE)
                   )
                 )
        ),

        tabPanel("Peaks",
                 icon = icon("mountain"),
                 br(),
                 h4("Detected Peaks"),
                 DTOutput("peaksTable"),
                 br(),
                 h4("Peak Statistics"),
                 verbatimTextOutput("peakStats")
        ),

        tabPanel("Comparison",
                 icon = icon("layer-group"),
                 br(),
                 h4("Spectra Overlay Comparison"),
                 plotlyOutput("overlayPlot", height = "600px"),
                 br(),
                 checkboxGroupInput("spectraToCompare", "Select Spectra to Compare:",
                                    choices = NULL, selected = NULL)
        ),

        tabPanel("Settings",
                 icon = icon("cog"),
                 br(),
                 h4("Application Settings"),

                 h5("Plot Settings"),
                 if (USE_COLOURPICKER) {
                   tagList(
                     colourInput("lineColor", "Spectrum Line Color:", value = "#0066CC"),
                     colourInput("peakColor", "Peak Marker Color:", value = "#FF6600")
                   )
                 } else {
                   tagList(
                     textInput("lineColor", "Spectrum Line Color (hex):", value = "#0066CC"),
                     textInput("peakColor", "Peak Marker Color (hex):", value = "#FF6600"),
                     helpText("Install 'colourpicker' package for color picker widget")
                   )
                 },
                 numericInput("plotHeight", "Plot Height (px):", value = 600, min = 400, max = 1200),

                 hr(),

                 h5("Export Settings"),
                 selectInput("exportFormat", "Export Format:",
                             choices = c("CSV", "Excel", "RData"),
                             selected = "CSV"),

                 hr(),

                 h5("Advanced"),
                 checkboxInput("verboseOutput", "Verbose Console Output", value = FALSE),
                 actionButton("resetSettings", "Reset to Defaults", class = "btn-warning")
        )
      )
    )
  )
)

# Server Logic
server <- function(input, output, session) {

  # Reactive values to store data
  values <- reactiveValues(
    spectra = NULL,
    processedSpectra = NULL,
    peaks = NULL,
    status = "Ready to import data"
  )

  # Import data
  observeEvent(input$dataFiles, {
    req(input$dataFiles)

    values$status <- paste("Importing", nrow(input$dataFiles), "file(s)...")

    tryCatch({
      # Import files
      spectraList <- list()

      for (i in 1:nrow(input$dataFiles)) {
        filePath <- input$dataFiles[[i, 'datapath']]
        fileExt <- tools::file_ext(input$dataFiles[[i, 'name']])

        if (fileExt %in% c("mzML", "mzXML")) {
          # Import using MALDIquantForeign
          spectraList[[i]] <- importMzMl(filePath)
        } else if (fileExt %in% c("txt", "csv")) {
          # Import from CSV/TXT
          data <- read.table(filePath, header = TRUE, sep = "\t")
          spectraList[[i]] <- createMassSpectrum(mass = data[,1], intensity = data[,2])
        }
      }

      values$spectra <- spectraList
      values$status <- paste("Successfully imported", length(spectraList), "spectra")

      # Update UI
      updateNumericInput(session, "spectrumIndex", max = length(spectraList))
      updateCheckboxGroupInput(session, "spectraToCompare",
                               choices = paste("Spectrum", 1:length(spectraList)),
                               selected = paste("Spectrum", 1:min(3, length(spectraList))))

    }, error = function(e) {
      values$status <- paste("Error importing data:", e$message)
    })
  })

  # Process data
  observeEvent(input$processBtn, {
    req(values$spectra)

    values$status <- "Processing spectra..."

    withProgress(message = 'Processing Data', value = 0, {

      tryCatch({
        spectra <- values$spectra

        # Smoothing
        if (input$doSmoothing) {
          incProgress(0.2, detail = "Applying smoothing...")

          # Map UI method names to R function method names
          smoothMethod <- switch(input$smoothMethod,
                                 "SavitzkyGolay" = "SavitzkyGolay",
                                 "MovingAverage" = "MovingAverage",
                                 "SavitzkyGolay") # default

          spectra <- smoothIntensity(spectra,
                                     method = smoothMethod,
                                     halfWindowSize = input$halfWindowSize)
        }

        # Baseline correction
        if (input$doBaseline) {
          incProgress(0.2, detail = "Removing baseline...")

          # Map UI method names to R function method names
          baselineMethod <- switch(input$baselineMethod,
                                   "SNIP" = "SNIP",
                                   "TopHat" = "TopHat",
                                   "ConvexHull" = "ConvexHull",
                                   "median" = "median",
                                   "SNIP") # default

          spectra <- removeBaseline(spectra,
                                    method = baselineMethod)
        }

        # Normalization
        incProgress(0.2, detail = "Normalizing...")
        spectra <- calibrateIntensity(spectra, method = "TIC")

        # Peak detection
        incProgress(0.2, detail = "Detecting peaks...")
        peaks <- detectPeaks(spectra,
                            SNR = input$snr,
                            halfWindowSize = input$halfWindowSizePeak)

        incProgress(0.2, detail = "Finalizing...")

        values$processedSpectra <- spectra
        values$peaks <- peaks
        values$status <- "Processing complete!"

      }, error = function(e) {
        values$status <- paste("Error during processing:", e$message)
      })
    })
  })

  # Status output
  output$statusInfo <- renderPrint({
    cat(values$status, "\n\n")
    if (!is.null(values$spectra)) {
      cat("Number of spectra loaded:", length(values$spectra), "\n")
    }
    if (!is.null(values$peaks)) {
      cat("Number of spectra processed:", length(values$peaks), "\n")
      cat("Total peaks detected:", sum(sapply(values$peaks, length)), "\n")
    }
  })

  # Plot spectra
  output$spectraPlot <- renderPlotly({
    req(values$processedSpectra)

    idx <- input$spectrumIndex
    if (idx > length(values$processedSpectra)) idx <- 1

    spectrum <- values$processedSpectra[[idx]]

    p <- plot_ly(x = mass(spectrum), y = intensity(spectrum),
                 type = 'scatter', mode = 'lines',
                 name = 'Spectrum',
                 line = list(color = input$lineColor)) %>%
      layout(title = paste("Spectrum", idx),
             xaxis = list(title = "m/z"),
             yaxis = list(title = "Intensity"))

    # Add peaks if available
    if (input$showPeaks && !is.null(values$peaks)) {
      peak <- values$peaks[[idx]]
      if (length(peak) > 0) {
        p <- p %>%
          add_trace(x = mass(peak), y = intensity(peak),
                    type = 'scatter', mode = 'markers',
                    name = 'Peaks',
                    marker = list(color = input$peakColor, size = 8))
      }
    }

    p
  })

  # Overlay plot
  output$overlayPlot <- renderPlotly({
    req(values$processedSpectra, input$spectraToCompare)

    p <- plot_ly()

    selected <- as.numeric(gsub("Spectrum ", "", input$spectraToCompare))

    for (i in selected) {
      if (i <= length(values$processedSpectra)) {
        spectrum <- values$processedSpectra[[i]]
        p <- p %>%
          add_trace(x = mass(spectrum), y = intensity(spectrum),
                    type = 'scatter', mode = 'lines',
                    name = paste("Spectrum", i))
      }
    }

    p %>% layout(title = "Spectra Overlay Comparison",
                 xaxis = list(title = "m/z"),
                 yaxis = list(title = "Intensity"))
  })

  # Peaks table
  output$peaksTable <- renderDT({
    req(values$peaks)

    # Combine all peaks into a data frame
    peakData <- data.frame()

    for (i in 1:length(values$peaks)) {
      peak <- values$peaks[[i]]
      if (length(peak) > 0) {
        df <- data.frame(
          Spectrum = i,
          Mass = round(mass(peak), 4),
          Intensity = round(intensity(peak), 2),
          SNR = round(snr(peak), 2)
        )
        peakData <- rbind(peakData, df)
      }
    }

    datatable(peakData, options = list(pageLength = 25, scrollX = TRUE))
  })

  # Peak statistics
  output$peakStats <- renderPrint({
    req(values$peaks)

    nPeaks <- sapply(values$peaks, length)

    cat("Peak Detection Summary\n")
    cat("======================\n\n")
    cat("Total spectra:", length(values$peaks), "\n")
    cat("Total peaks detected:", sum(nPeaks), "\n")
    cat("Average peaks per spectrum:", round(mean(nPeaks), 2), "\n")
    cat("Min peaks:", min(nPeaks), "\n")
    cat("Max peaks:", max(nPeaks), "\n")
  })

  # Download results
  output$downloadResults <- downloadHandler(
    filename = function() {
      paste0("maldiquant_results_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".csv")
    },
    content = function(file) {
      req(values$peaks)

      peakData <- data.frame()

      for (i in 1:length(values$peaks)) {
        peak <- values$peaks[[i]]
        if (length(peak) > 0) {
          df <- data.frame(
            Spectrum = i,
            Mass = mass(peak),
            Intensity = intensity(peak),
            SNR = snr(peak)
          )
          peakData <- rbind(peakData, df)
        }
      }

      write.csv(peakData, file, row.names = FALSE)
    }
  )

  # Download plot
  output$downloadPlot <- downloadHandler(
    filename = function() {
      paste0("spectrum_plot_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".png")
    },
    content = function(file) {
      req(values$processedSpectra)

      png(file, width = 1200, height = 800, res = 150)

      idx <- input$spectrumIndex
      spectrum <- values$processedSpectra[[idx]]

      plot(spectrum, main = paste("Spectrum", idx),
           xlab = "m/z", ylab = "Intensity")

      if (input$showPeaks && !is.null(values$peaks)) {
        points(values$peaks[[idx]], col = "red", pch = 4)
      }

      dev.off()
    }
  )

  # Reset settings
  observeEvent(input$resetSettings, {
    if (USE_COLOURPICKER) {
      updateColourInput(session, "lineColor", value = "#0066CC")
      updateColourInput(session, "peakColor", value = "#FF6600")
    } else {
      updateTextInput(session, "lineColor", value = "#0066CC")
      updateTextInput(session, "peakColor", value = "#FF6600")
    }
    updateNumericInput(session, "plotHeight", value = 600)
    updateSelectInput(session, "exportFormat", selected = "CSV")
    updateCheckboxInput(session, "verboseOutput", value = FALSE)
  })
}

# Run the application
shinyApp(ui = ui, server = server)
