####################################################################################
#
#                             Parts of Speech
#
####################################################################################

library(shiny)

# Function to clean the text
text.clean = function(x)
  # text data
{
  require("tm")
  x  =  gsub("<.*?>", " ", x)               # regex for removing HTML tags
  x  =  iconv(x, "latin1", "ASCII", sub = "") # Keep only ASCII characters
  x  =  gsub("[^[:alnum:]]", " ", x)        # keep only alpha numeric
  x  =  tolower(x)                          # convert to lower case characters
  x  =  removeNumbers(x)                    # removing numbers
  x  =  stripWhitespace(x)                  # removing white space
  x  =  gsub("^\\s+|\\s+$", "", x)          # remove leading and trailing white space
  return(x)
}

# Server logic
shinyServer(function(input, output) {
  
  # Read input text file content
  Dataset <- reactive({
    # Error handling with use friendly error message
    validate(need(!(is.null(input$dataFile)), "Please select a input data file (.txt)"))
    
    require(stringr)
    fileContent <- readLines(input$dataFile$datapath)
    fileContent <- text.clean(fileContent)
    return(fileContent)
  })
  
  # Load udpipe model and annotate the document
  annoDoc <- reactive({
    # Error handling
    validate(need(!(is.null(input$udpipeModel$datapath)), "Please select a udpipe model (.udpipe file)"))
    
    # load selected language model for annotation
    model <- udpipe_load_model(input$udpipeModel$datapath)
    
    withProgress(message = "Processing...", {
      # annotate text dataset using selected udpipe model
      aDoc <- udpipe_annotate(model, x = Dataset())
      aDoc <- as.data.frame(aDoc)
    })
    
    return(aDoc)
  })
  
  # Build UPOS string
  uposSelected <- reactive({
    # Error handling
    validate(need(!(is.null(input$XPOS)),"Please select a parts of speech tags to be included."))
    
    uposStr <- ''
    for (elem in input$XPOS) {
      switch(
        elem,
        "JJ" = {
          uposStr <- c(uposStr, "ADJ")
        },
        "NN" = {
          uposStr <- c(uposStr, "NOUN")
        },
        "NNP" = {
          uposStr <- c(uposStr, "PROPN")
        },
        "RB" = {
          uposStr <- c(uposStr, "ADV")
        },
        "VB" = {
          uposStr <- c(uposStr, "VERB")
        }
      )
    }
    return(uposStr)
  })
  
  # Filter the doc based on user selection and draw co-occurance plot
  output$coocPlot <- renderPlot({
    
    validate(need(!(is.null(input$XPOS)),"Please select a parts of speech tags to be included."))
    
    # Sentence Co-occurrence
    x_cooc <- cooccurrence(
      x = subset(annoDoc(), xpos %in% input$XPOS), # filter using selected XPOS
      term = "lemma",
      group = c("doc_id", "paragraph_id", "sentence_id")
    )
    
    # Draw Co-occurance plot
    wordnetwork <- head(x_cooc, input$topn) # use top n terms
    wordnetwork <- igraph::graph_from_data_frame(wordnetwork)
    
    ggraph(wordnetwork, layout = "fr") +
      
      geom_edge_link(aes(width = cooc, edge_alpha = cooc), edge_colour = "orange") +
      geom_node_text(aes(label = name), col = "darkgreen", size = 4) +
      
      theme_graph(base_family = "Arial Narrow") +
      theme(legend.position = "none") +
      
      labs(title = "Co-occurrence Plot : XPOS")
  })
  
  # Draw bar chart of frequencies for selected XPOS
  output$freqPlot <- renderPlot({
    
    validate(need(!(is.null(input$XPOS)),"Please select a parts of speech tags to be included."))
    
    # Show progress bar for visual feedback
    withProgress(message = "Processing...", {
      
      cmn_xpos =  subset(annoDoc(), xpos %in% input$XPOS)
      freqTable <- txt_freq(cmn_xpos$xpos)
      freqTable$key <- factor(freqTable$key, levels = rev(freqTable$key))
      barchart(
        key ~ freq,
        data = freqTable,
        col = "lightblue",
        main = "XPOS (Parts of Speech) : frequency of occurrence",
        xlab = "Frequency"
      )
    })
  })
  
  #UPOS co-occurance plot
  output$coocPlotUpos <- renderPlot({
    
    # Sentence Co-occurrence
    x_cooc <- cooccurrence(
      x = subset(annoDoc(), upos %in% uposSelected()), # filter using selected UPOS
      term = "lemma",
      group = c("doc_id", "paragraph_id", "sentence_id")
    )
    
    # Draw Co-occurance plot
    wordnetwork <- head(x_cooc, input$topn) # use top n terms
    wordnetwork <- igraph::graph_from_data_frame(wordnetwork)
    
    ggraph(wordnetwork, layout = "fr") +
      
      geom_edge_link(aes(width = cooc, edge_alpha = cooc), edge_colour = "orange") +
      geom_node_text(aes(label = name), col = "darkgreen", size = 4) +
      
      theme_graph(base_family = "Arial Narrow") +
      theme(legend.position = "none") +
      
      labs(title = "Co-occurrence Plot : UPOS")
  })
  
  # Draw bar chart of frequencies for selected UPOS
  output$freqPlotUPOS <- renderPlot({
    
    # Show progress bar for visual feedback
    withProgress(message = "Processing...", {
      
      cmn_upos =  subset(annoDoc(), upos %in% uposSelected())
      freqTable <- txt_freq(cmn_upos$upos)
      freqTable$key <- factor(freqTable$key, levels = rev(freqTable$key))
      barchart(
        key ~ freq,
        data = freqTable,
        col = "lightblue",
        main = "UPOS (Parts of Speech) : frequency of occurrence",
        xlab = "Frequency"
      )
    })
  })
  
  # Draw XPOS table
  output$xposTable <- renderTable({
    out <- table(annoDoc()$xpos)
    out
  })
  
  # Draw UPOS table
  output$uposTable <- renderTable({
    out <- table(annoDoc()$upos)
    out
  })

})
