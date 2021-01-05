library(shiny)
library(shinydashboard)
library(shinyjs)

# Define UI for application
dashboardPage(
  # Application title
  dashboardHeader(title = "Genetic Algorithm Example"),
  
  dashboardSidebar(
    sliderInput(
      "pop_size",
      label = "Population Size",
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
  
  dashboardBody(
    useShinyjs(),
    fluidRow(
      infoBox(
        title = "Iteration",
        value = uiOutput("iteration_count"),
        icon = icon("redo")
      ),
      infoBox(
        title = "Best Fitness",
        value = uiOutput("best_fitness"),
        icon = icon("thumbs-up")
      )
    ),
    fluidRow(
      box(title = "All Solutions in Population", plotOutput("population_plot")),
      box(title = "Fitness", plotOutput("fitness_plot"))
    )
  )
  
)
