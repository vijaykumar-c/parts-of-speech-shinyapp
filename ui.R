####################################################################################
#  
#                             Parts of Speech
#                     
####################################################################################


library(shiny)

# Reset upload size to accomodate the udpipe model file sizes 
options(shiny.maxRequestSize = 30*1024^2)

# Define UI for application that draws a histogram
shinyUI(
  fluidPage(
    
    titlePanel("PartsOfSpeech Exploration - udpipe"),
    
    sidebarLayout( 
      sidebarPanel(  
        
        fileInput("dataFile", "Upload data (Select text file)",
                  accept = c("text", "text/plain", ".txt")),
        
        fileInput("udpipeModel", "Upload udpipe model (Select .udpipe file)",
                  accept = c("udpipe", "udpipe", ".udpipe")),
        hr(),
        
        checkboxGroupInput("XPOS", "Select parts of speech tags:",
                           c("adjective" = "JJ",
                             "noun" = "NN",
                             "proper noun" = "NNP",
                             "adverb" = "RB",
                             "verb" = "VB"),
                           c("adjective" = "JJ",
                             "noun" = "NN",
                             "proper noun" = "NNP")),
        
        sliderInput("topn", "Top n terms for co-occurance:",
                    min = 10, max = 100,
                    value = 50),
        
        submitButton(text = "Apply Changes", icon = NULL, width = NULL)
        ), # end of sidebar panel
      
      mainPanel(
        
        tabsetPanel(type = "tabs",
                    
                    tabPanel("Overview",
                             h4(p("Data input")),
                             p("1. Data: Data to be analysed in text (.txt) file.",align="justify"),
                             p("2. udpipe model: .udpipe file corresonding to the input data file language ",align="justify"),
                             #p("Please refer to the link below for sample csv file."),
                             #a(href="https://github.com/sudhir-voleti/sample-data-sets/blob/master/Segmentation%20Discriminant%20and%20targeting%20data/ConneCtorPDASegmentation.csv"
                            #   ,"Sample data input file"),   
                             br(),
                             h4('How to use this App'),
                            p('1. Click on', span(strong("Upload data (Select text file)")), 'and upload the data in text file (.txt format).',align="justify"),
                            p('2. Click on', span(strong("Upload udpipe model (Select .udpipe file)")), 'and upload the udpipe model for the corresponding language for data in selected text file.',align="justify"),
                            p('3.', span(strong("Select the specific parts of speech tags")), 'to be used for analysis from the list. 
                                  (Defalut selection is - adjective,noun,proper noun)',align="justify"),
                            p('4.',span(strong("Select number of top n terms for plotting the occurance plot")), 'for the analysis. Move the slider to select the number of terms.',align="justify"),
                            p('5. Click on', span(strong("Apply Changes")), 'button to reprocess the data based on changes.',align="justify")),
                            
                    tabPanel("Co-occurance Plot", 
                                 plotOutput('coocPlot'),hr(),plotOutput('coocPlotUpos')),
                    
                    tabPanel("Frequency Plot(XPOS)", 
                             plotOutput('freqPlot'),tableOutput('xposTable')),
                    
                    #tabPanel("Frequency Table(XPOS)",
                    #         tableOutput('xposTable')),
                    
                    #tabPanel("Co-occurance Plot (UPOS)", 
                   #          plotOutput('coocPlotUpos')),
                    
                    tabPanel("Frequency Plot (UPOS)", 
                             plotOutput('freqPlotUPOS'),tableOutput('uposTable'))
                    
                    #tabPanel("Frequency Table(UPOS)",
                    #         tableOutput('uposTable'))
                    
        ) # end of tabsetPanel
      )# end of main panel
    ) # end of sidebarLayout
  )  # end if fluidPage
) # end of UI

