(import cmd)

(use judge)

(use ./parse-md)


(def version "0.0.0-a")

(defn basename [path]
  (last (string/split "/" path)))

(defn find-all-arcd-files [path &opt explicit results]
  (default explicit true)
  (default results @[]) 
  
  (unless (string/has-prefix? "." (basename path))
    (case (os/stat path :mode)
      :directory
      (each entry (os/dir path)
        (find-all-arcd-files (string path "/" entry) false results))
      :file
      (if (string/has-suffix? ".arcd" path)
        (array/push results path))
      nil
      (array/push results [(string/format "could not read %q" path)])))
  
  results)

(cmd/defn handle-version "" [] 
  (print "arcdown v" version))

(cmd/defn handle-ascii ""
          []
          (print "Generate an ASCII file of an arc diagram"))

(cmd/defn handle-image ""
          []
          (print "Generate an image of an arc diagram"))

(cmd/main 
 (cmd/fn
  (string/format
   ```
   arcdown v%s

   Usage: arcdown [subcommand] {positional arguments} [options]
   
   A simple CLI tool for extracting data and metadata from correctly formatted Markdown files to create Arc diagrams, in either ASCII or full-color image.
   ``` version)
  [[--version -v] (effect |((print "Version " version) (os/exit 0)))
   [--watch -w] (flag)
   [--image -i] (flag)
   [--ascii -a] (flag)
   file (optional :file)] 

  (var arcd-files @[])
  (case (os/stat (or file (os/cwd)) :mode)
      :directory (array/push arcd-files ;(find-all-arcd-files (or file (os/cwd))))
      :file (array/push arcd-files (or file (os/cwd))))

  
  # TODO: What if there's more than one arc defined in the same file?
  (def arcs
    (seq [file :in arcd-files]
      (peg/match arcdown-peg (slurp file))))
  
  # Refer to Mendoza implementation for example of how to `watch`
  # - https://github.com/bakpakin/mendoza/blob/master/mendoza/init.janet#L162-L165
  
  
  ))