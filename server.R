library(shiny)
library(future)
library(ipc)
library(GA)
library(ggplot2)
library(dplyr)
library(tidyr)
library(shinyjs)

plan(multiprocess)

rastrigin <- function(x1, x2)
{
  20 + x1^2 + x2^2 - 10*(cos(2*pi*x1) + cos(2*pi*x2))
}


# Define server logic 
server <- function(input, output) {
  
  queue <- shinyQueue()
  queue$consumer$start(100) 
  
  iteration <- reactiveVal(0)
  best_fitness <- reactiveVal(NA)
  population <- reactiveVal(NA)
  fitness_summary <- reactiveVal(NA)
  optimising <- reactiveVal(FALSE)
  
  
  observeEvent(input$run_opt, {
    
    future({

      queue$producer$fireAssignReactive("optimising", TRUE)
      
      shiny_monitor <- function(x){
        queue$producer$fireAssignReactive("iteration", x@iter)
        queue$producer$fireAssignReactive("best_fitness", max(x@fitness))
        queue$producer$fireAssignReactive("population", x@population)
        queue$producer$fireAssignReactive("fitness_summary", x@summary)
        Sys.sleep(0.1)
      } 
      
      ga <- ga(type = "real-valued", fitness =  function(x) -rastrigin(x[1], x[2]),
               lower = c(-5.12, -5.12), upper = c(5.12, 5.12),
               popSize = isolate(input$pop_size),
               pmutation = isolate(input$mutation_prob),
               pcrossover = isolate(input$crossover_prob),
               maxiter = isolate(input$iter_num),
               monitor = shiny_monitor)
      
      queue$producer$fireAssignReactive("optimising", FALSE)
      
      ga
    })
    
    # Return something so as to not block the UI
    NULL
    
  })
  
  # Disable run button if currently optimising
  observe({
    if(optimising()){
      disable("run_opt")
    } else {
      enable("run_opt")
    }
  })
  
  # Render outputs
  
  output$iteration_count <- renderText({
    req(iteration())
  })
  
  
  output$best_fitness <- renderText({
    format(req(best_fitness()), digits = 5)
  })
  
  output$population_plot <- renderPlot({
    pop <- req(population())
    pop <- as.data.frame(pop)
    
    
    ggplot(pop, 
           aes(V1, V2)) +
      geom_point(alpha = 0.5) +
      coord_equal() +
      xlim(-5.12, 5.12) +
      ylim(-5.12, 5.12)
    
  })
  
  output$fitness_plot <- renderPlot({
    fitness_graph <- req(fitness_summary()) 
    
    fitness_graph %>% 
      as.data.frame() %>% 
      select(max, mean, median) %>% 
      mutate(iteration = row_number()) %>% 
      gather(key = "fitness", 
             value = "value", 
             -iteration) %>% 
      ggplot(aes(iteration, value, col = fitness)) + geom_line()
    
  })
  
}