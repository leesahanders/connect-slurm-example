# From: https://github.com/michaelmayer2/penguins-hpc/blob/main/app.R 

#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinyWidgets) # https://dreamrs.github.io/shinyWidgets/reference/progress-bar.html
#library(progress) # https://stackoverflow.com/questions/5423760/how-do-you-create-a-progress-bar-when-using-the-foreach-function-in-r?rq=4 and https://github.com/r-lib/progress/issues/97
#library(spsComps) # https://stackoverflow.com/questions/30474538/possible-to-show-console-messages-written-with-message-in-a-shiny-ui

Sys.setenv(PATH=paste0("/opt/slurm/bin:",Sys.getenv("PATH")))

plot_it <- function(res, bins) {
  # Plot routine
  library(cowplot)
  library(ggplot2)
  
  intercept <-
    ggplot(as.data.frame(res), aes(x = `(Intercept)`)) + geom_histogram(bins =
                                                                          bins)
  
  xind <-
    ggplot(as.data.frame(res), aes(x = `x[ind, 1]`)) + geom_histogram(bins =
                                                                        bins)
  
  plot_grid(intercept, xind, labels = "AUTO")
}

compute <- function(trials, cores, session) {
  print("success")
  
  cmq_method <- config::get("cmq_method")
  
  if (cmq_method == "slurm") {
    options(clustermq.scheduler = "slurm",
            clustermq.template = "./slurm.tmpl",
            clustermq.data.warning = 100
    )
  }
  if (cmq_method == "ssh") {
    options(clustermq.scheduler = "ssh",
            clustermq.template = "./ssh.tmpl",
            clustermq.ssh.host = config::get("cmq_remote_host") # use your user and host, obviously
            #clustermq.ssh.log = "~/cmq_ssh.log" # log for easier debugging
    )
  }
  
  # Loading libraries
  library(clustermq)
  library(foreach)
  library(palmerpenguins)
  library(progressr)
  
  # Register parallel backend to foreach
  register_dopar_cmq(
    n_jobs = cores,
    memory = 1024,
    log_worker = TRUE, # FALSE
    export = list(session=session),
    template=list(log_file = "clmq.%a")
    # template=list(log_file = "/tmp/clmq.%a")
    #chunk_size = trials / 5 / cores
  )
  
  # Our dataset
  x <- as.data.frame(penguins[c(4, 1)])
  
  # Number of trials to simulate
  trials <- trials
  # Main loop
  withProgressShiny(
    detail = 'This may take a while...',
    message = 'Calculation in progress',
    value = NULL,
    foreach(
      i = 1:trials,
      .combine = rbind,
      .packages = c("shiny")
    ) %dopar% {
      ind <- sample(344, 344, replace = TRUE)
      result1 <-
        glm(x[ind, 2] ~ x[ind, 1], family = binomial(logit))
      coefficients(result1)
      # >>> SOME PROGRESS BAR HERE <<<   
    }
  )
}

# logify from https://stackoverflow.com/questions/30502870/shiny-slider-on-logarithmic-scale
# logifySlider javascript function
JS.logify <-
  "
// function to logify a sliderInput
function logifySlider (sliderId, sci = false) {
  if (sci) {
    // scientific style
    $('#'+sliderId).data('ionRangeSlider').update({
      'prettify': function (num) { return ('10<sup>'+num+'</sup>'); }
    })
  } else {
    // regular number style
    $('#'+sliderId).data('ionRangeSlider').update({
      'prettify': function (num) { return (Math.pow(10, num)); }
    })
  }
}"

# call logifySlider for each relevant sliderInput
JS.onload <-
  "
// execute upon document loading
$(document).ready(function() {
  // wait a few ms to allow other scripts to execute
  setTimeout(function() {
    // include call for each slider
    logifySlider('trials', sci = false)
  }, 5)})
"

# Define UI for application that draws a histogram
ui <- fluidPage(
  tags$head(tags$script(HTML(JS.logify))),
  tags$head(tags$script(HTML(JS.onload))),
  
  # Application title
  titlePanel("Penguins"),
  
  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
      sliderInput(
        "trials",
        "Number of Trials:",
        min = 2,
        max = 6,
        value = 2,
        step = 0.5
      ),
      
      sliderInput(
        "bins",
        "Number of bins:",
        min = 10,
        max = 200,
        value = 100
      ),
      sliderInput(
        "cores",
        "Numbers of core:",
        min = 1,
        max = 200,
        value = 1
      ),
      
      # Show a text field for troubleshooting
      verbatimTextOutput("urlText")
    ),
    # Show a plot of the generated distribution
    mainPanel(plotOutput("distPlot"))
  
  )
)

# Define server logic required to draw a histogram
server <- function(input, output, session) {
  output$urlText <- renderText({
    paste(sep = "",
          # "protocol: ", session$clientData$url_protocol, "\n",
          # "hostname: ", session$clientData$url_hostname, "\n",
          # "pathname: ", session$clientData$url_pathname, "\n",
          # "port: ",     session$clientData$url_port,     "\n",
          # "search: ",   session$clientData$url_search,   "\n",
          # "sys info user: ",   Sys.info()[["user"]],   "\n",
          # "session clientdata user: ",   session$clientData$user,   "\n",
          "\n", "session user: ",   session$user,   "\n",
          "\n", "working directory: ",   getwd(),   "\n"
    )
  })
  
  # Initialize with dummy value
  res <- 1
  
  # res is a reactiveValue so that it can be used in observeEvent()
  # and still be used in output$distPlot
  rv <- reactiveValues(res = res)
  
  # Various events
  observeEvent(input$trials, {
    cat("Running", 10 ^ input$trials, "trials\n")
    rv$res <- compute(10 ^ input$trials, input$cores, session)
  })
  observeEvent(input$bins, {
    cat("Setting", input$bins, "bins\n")
  })
  observeEvent(input$cores, {
    cat("Setting", input$cores, "cores\n")
    rv$res <- compute(10 ^ input$trials, input$cores, session)
  })
  
  # Plot the histogram
  output$distPlot <- renderPlot({
    plot_it(rv$res, input$bins)
  })
  
}

# Run the application
shinyApp(ui = ui, server = server)