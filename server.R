library(shiny)
library(future)
library(ipc)
library(GA)
library(ggplot2)
library(dplyr)
library(tidyr)
library(shinyjs)
library(png)
library(ggpubr)

# Define plan for async process using future package
plan(multiprocess)

# Objective function for optimisation (https://en.wikipedia.org/wiki/Rastrigin_function)
rastrigin <- function(x1, x2)
{
  20 + x1^2 + x2^2 - 10*(cos(2*pi*x1) + cos(2*pi*x2))
}

# Prepare background for population plot so no need to render in each iteration
rast_bg_img <- readPNG("www/rast_plot_small.png")

rast_canvas <- ggplot() +
  background_image(rast_bg_img) +
  coord_equal() +
  xlim(-5.12, 5.12) +
  ylim(-5.12, 5.12) +
  xlab("X1") +
  ylab("X2")


# Define server logic 
server <- function(input, output) {
  
  # Inititialise future
  queue <- shinyQueue()
  queue$consumer$start(100) 
  
  # Reactive values to store optimisation outputs
  iteration <- reactiveVal(0)
  fitness <- reactiveVal(NA)
  population <- reactiveVal(NA)
  fitness_summary <- reactiveVal(NULL)
  optimising <- reactiveVal(FALSE)
  
  # Run optimisation when button clicked 
  observeEvent(input$run_opt, {
    
    future({
      # So we can disable the optimise button
      queue$producer$fireAssignReactive("optimising", TRUE)
      
      # Custom monitor function for GA returns data to the reactive values
      shiny_monitor <- function(x){
        queue$producer$fireAssignReactive("iteration", x@iter)
        queue$producer$fireAssignReactive("fitness", x@fitness)
        queue$producer$fireAssignReactive("population", x@population)
        queue$producer$fireAssignReactive("fitness_summary", x@summary)
        Sys.sleep(0.1)
      } 
      
      # The Genetic Algorithm
      ga <- ga(type = "real-valued", fitness =  function(x) -rastrigin(x[1], x[2]),
               lower = c(-5.12, -5.12), upper = c(5.12, 5.12),
               popSize = isolate(input$pop_size),
               pmutation = isolate(input$mutation_prob),
               pcrossover = isolate(input$crossover_prob),
               maxiter = isolate(input$iter_num),
               elitism = base::max(1, round(isolate(input$pop_size) * isolate(input$elitism))), 
               monitor = shiny_monitor)
      
      # So we can enable the optimise button
      queue$producer$fireAssignReactive("optimising", FALSE)
      
      # Return outputs of GA
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
  
  # Iteration
  output$iteration_count <- renderText({
    req(iteration())
  })
  
  # Best fitness
  output$best_fitness <- renderText({
    format(max(req(fitness())) * -1, digits = 5)
  })
  
  # Population plot
  output$population_plot <- renderPlot({
    # Display blank canvas if optimisation not yet run
    if(is.na(population())){
      rast_canvas
    } else {
      pop <- req(population())
      pop <- as.data.frame(pop)
      
      rast_canvas +
        geom_point(data = pop, aes(V1, V2), colour = "red")
    }
  })
  
  # Fitness plot
  output$fitness_plot <- renderPlot({
    fitness_graph <- req(fitness_summary()) 
    
    fitness_graph %>% 
      as.data.frame() %>% 
      select(best = max, mean, median) %>% 
      mutate(iteration = row_number()) %>% 
      gather(key = "fitness", 
             value = "value", 
             -iteration) %>% 
      filter(complete.cases(.)) %>% 
      mutate(value = value * -1) %>% 
      ggplot(aes(iteration, value, col = fitness)) + geom_line()
    
  })
  
  # Best solution for x1 and x2
  output$best_x1 <- renderText({
    req(population())[which.max(req(fitness()))[1], ][1]
  })
  
  output$best_x2 <- renderText({
    req(population())[which.max(req(fitness()))[1], ][2]
  })
  
}