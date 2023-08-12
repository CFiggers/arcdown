(declare-project
  :name "arcdown"
  :description "A CLI tool that extracts data and metadata from correctly-formatted Markdown files and creates Arc diagrams in ASCII and Image formats."
  :dependencies ["https://github.com/ianthehenry/cmd.git"
                 "https://github.com/andrewchambers/janet-jdn"]) 
   
(declare-executable
  :name "arcd"
  :entry "src/arcdown.janet"
  # :lflags ["-static"]
  :install false)