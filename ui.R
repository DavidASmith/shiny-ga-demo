

library(shiny)
library(shinydashboard)

# Define UI for application 
dashboardPage(
  # Application title
  dashboardHeader(title = "Genetic Algorithm Example"),
  
  dashboardSidebar(
    sliderInput(
      "pop_size",
      label = "Population",
      min = 2,
      max = 200,
      value = 50
    ),
    sliderInput(
      "mutation_prob",
      label = "Mutation Probability",
      min = 0,
      max = 1,
      value = 0.1
    ),
    sliderInput(
      "crossover_prob",
      label = "Crossover Probability",
      min = 0,
      max = 1,
      value = 0.8
    ),
    numericInput("iter_num",
                 "Iterations",
                 value = 100),
    actionButton("run_opt",
                 "Run")
  ),
  
  dashboardBody(fluidRow(
    infoBox(title = "Iteration", value = uiOutput("iteration_count")),
    infoBox(title = "Best Fitness", value = uiOutput("best_fitness"))
  ),
  fluidRow(
    box(title = "All Solutions in Population", plotOutput("population_plot")),
    box(title = "Fitness", plotOutput("fitness_plot"))
  ))
  
)
