(use judge)

(defn dedent [str]
  (let [indent-peg '(* (<- :s*) (<- (* (any 1) -1)))
        lines (string/split "\n" str) 
        indents (map |(peg/match indent-peg $) lines)
        least-indent (min ;(map (comp length first) indents))]
    (string/join (map |(string/slice $ least-indent) lines) "\n")))

(deftest "test dedent"
  (def mlstring
  ```
      Thing
         Thing  
  ```)
  (test (dedent mlstring) "Thing\n   Thing  "))

(defn parse-outline [in-str] 
  (var return-tree @[])
  (var stack @[])
  
  (let [split-indent-peg '(* (<- :s*) "- " (<-(to (+ (* :s* -1) -1))) :s*)
        lines (map |(peg/match split-indent-peg $) (string/split "\n" in-str))
        nodes (map |{:indent (length (get $ 0)) :content (get $ 1) :children @[]} lines)]
    # For each node:
    (each node nodes
      
      # Only if the stack is empty...
      (when (not (empty? stack))
        (while (< (node :indent) ((array/peek stack) :indent))
          # Pop all subordinate nodes
          (array/pop stack)) 
        (when (= (node :indent) ((array/peek stack) :indent))
          # Pop sibling node (only possible to have max of one sibling at any time)
          (array/pop stack))) 

      # If stack is empty after the above...
      (if (empty? stack)
        # `node` is a root, push onto `return-tree`
        (array/push return-tree node) 
        # Otherwise, `node` is a Child, add to children of current end of stack
        (array/push ((array/peek stack) :children) node)) 

      # ALSO add directly onto the stack regardless
      (array/push stack node)))
  
  # Return the tree
  return-tree)
