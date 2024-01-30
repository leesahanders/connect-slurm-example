#https://stackoverflow.com/questions/54532486/using-standard-r-shiny-progress-bar-in-parallel-foreach-calculations?rq=4

library(shiny)
library(future)
library(promises)
library(ipc)

plan(multisession)


ui <- fluidPage(
  actionButton(inputId = "go", label = "Launch calculation")
)

server <- function(input, output, session) {
  
  observeEvent(input$go, {
    
    progress = AsyncProgress$new(message="Complex analysis")
    
    future({
      for (i in 1:15) {
        progress$inc(1/15)
        Sys.sleep(0.5)
      }
      
      progress$close()
      return(i)
    })%...>%
      cat(.,"\n")
    
    Sys.sleep(1)
    
    progress2 = AsyncProgress$new(message="Complex analysis")
    
    future({
      for (i in 1:5) {
        progress2$inc(1/5)
        Sys.sleep(0.5)
      }
      
      progress2$close()
      
      return(i)
    })%...>%
      cat(.,"\n")
    
    NULL
  })
}

shinyApp(ui = ui, server = server)