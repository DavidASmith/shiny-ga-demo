library(shiny)
library(shinydashboard)
library(shinyjs)

# Shiny dashboard UI
dashboardPage(
  # Application title
  dashboardHeader(title = "Genetic Algorithm Example"),
  # Sidebar options
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
    sliderInput(
      "elitism",
      label = "Elitism",
      min = 0,
      max = 1,
      value = 0.05
    ),
    numericInput("iter_num",
                 "Iterations",
                 value = 100),
    actionButton("run_opt",
                 "Run")
  ),
  # Outputs
  dashboardBody(
    useShinyjs(),
    fluidRow(
      infoBox(
        title = "Iteration",
        value = uiOutput("iteration_count"),
        icon = icon("redo"), 
        width = 3
      ),
      infoBox(
        title = "Best Fitness",
        value = uiOutput("best_fitness"),
        icon = icon("thumbs-up"), 
        width = 3
      ),
      infoBox(
        title = "Best X1",
        value = uiOutput("best_x1"),
        icon = icon("thumbs-up"), 
        width = 3
      ),
      infoBox(
        title = "Best X2",
        value = uiOutput("best_x2"),
        icon = icon("thumbs-up"), 
        width = 3
      )
    ),
    fluidRow(
      box(title = "All Solutions in Population", plotOutput("population_plot")),
      box(title = "Fitness", plotOutput("fitness_plot"))
    ),
    fluidRow(
      box(title = "What is this?", 
          "This is an interactive example of using a genetic algorithm to solve a simple problem. 
          Here we're attempting to find the optimum values for X1 and X2 to minimise the objective 
          function. We're using a Rastrigin function as the objective. You can see this plotted in 
          the population plot above. Note that there are many local minima (darker colors are lower). 
          The optimum value for both X1 and X2 is zero which also return zero from the objective function.", 
          br(), br(),
          "Each red dot in the plot on the left represents an individual in the population. The plot on the 
          right shows the best, mean, and median fitness over all iterations of the algorithm.",
          br(), br(), 
          "You can try different parameters for the genetic algorithm to explore how these affect the outcome.")
    )
  )
)
