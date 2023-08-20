(import jdn)
(use judge)

(def kv-line-peg
  ~{:key (<- (to ":"))
    :value (<- (to "\n"))
    :line (/ (* :s* :key ":" :s* :value "\n") ,|{$0 $1})
    :main (some :line)})

(def front-matter-peg 
  ~{:separator "---\n" 
    :front-matter (* :separator (/ (<- (to :separator)) ,|(peg/match kv-line-peg $)) :separator)
    :main (/ :front-matter ,|{:front-matter (merge ;$)})})

(def md-table-peg 
  ~{:raw-row (* (<- (to (+ "\n" -1))) (? "\n"))
   :header (/ (* :raw-row (* (some (set "|- ")) "\n")) 
              ,|(array/slice (map string/trim (string/split "|" $)) 1 -2))
   :row (/ :raw-row ,|(array/slice (map string/trim (string/split "|" $)) 1 -2))
   :main (* :header (some :row))})

(def arc-text-peg
  ~{:begin-arc-text (* "<!--" :s* "BEGIN:ARCTEXT" :s* "-->" :s*)
    :end-arc-text (* "<!--" :s* "END:ARCTEXT" :s* "-->" :s*)
    :main (/ (* :begin-arc-text (<- (to :end-arc-text)) :end-arc-text) 
             ,|{:arc-text (peg/match md-table-peg $)})})

(def arc-jdn-peg
  ~{:begin-arc-jdn (* "<!--" :s* "BEGIN:ARCJDN" :s* "-->" :s*)
    :end-arc-jdn (* "<!--" :s* "END:ARCJDN" :s* "-->")
    :codeblock (* "```" (? "janet") :s*)
    :main (/ (* :begin-arc-jdn :codeblock (<- (to :codeblock)) :codeblock :end-arc-jdn) 
             ,|{:arc-jdn (jdn/decode $)})})

(def main-point-peg
  ~{:begin-main-point (* "<!--" :s* "BEGIN:MAINPOINT" :s* "-->" :s*)
    :end-main-point (* :s* "<!--" :s* "END:MAINPOINT" :s* "-->")
    :main (/ (* :begin-main-point (<- (to :end-main-point)) :end-main-point) 
             ,|{:main-point $})})

(def arcdown-peg 
  (peg/compile
   ~{:front-matter ,front-matter-peg
     :arc-text ,arc-text-peg
     :arc-jdn ,arc-jdn-peg
     :main-point ,main-point-peg
     :main (* (? :front-matter) 
              (some (* (to (+ :arc-text :arc-jdn :main-point)) 
                       (+ :arc-text :arc-jdn :main-point))) 
              (some 1))}))

(defn hiccup-to-ast [hiccup]
    (match hiccup 
      ([x & rest] (not (indexed? x)))
      (merge (case (type x)
               :string {:type :branch :label x}
               :keyword {:type :node :kind x}
               {:type [:error x]})
             ;(seq [x :in rest] 
                (cond (dictionary? x) x 
                      (all indexed? x) {:children (map hiccup-to-ast x)} 
                      {:children @[(hiccup-to-ast x)]})))
      ([& xs] (all indexed? xs))
      (map hiccup-to-ast xs)
      x [:error x])) 

(defn parse-arcd-file [file]
  (-> (merge ;(peg/match arcdown-peg file)) 
      (update :arc-jdn hiccup-to-ast)))

(def ast 
  @{:type :node
    :kind :Idea/Explanation
    :children @[@{:label "Idea"
                  :leaf 1
                  :main 1
                  :type :branch}
                @{:children @{:children @[@{:label "Negative"
                                            :leaf 2
                                            :type :branch}
                                          @{:label "Positive"
                                            :leaf 3
                                            :main 1
                                            :type :branch}]
                              :kind :Negative/Positive
                              :type :node}
                  :label "Explanation"
                  :type :branch}]})

(defn width [str]
  (length (string/replace-all "─" "-" str)))

(defn traverse-arcd-ast [ast &opt local-max]
  (default local-max 0)
  (def index |(if (indexed? $) $ [$]))
  (match ast
    
    ################## Leaf ##################
    {:leaf x :label l}
    (-> ast 
        (put :x-position-begin 0)
        (put :x-position-label 5)
        (put :x-position-end (+ 4 (length l) 3))
        (put :y-position (dec (* x 2)))
        (put :ascii (string (string/format "% 2d" x) 
                            " <─" l 
                            (if (ast :main) "─*─" "───"))))
    
    ################## Branch ##################
    {:type :branch :children _ :label l}
    (do (set (ast :children)
             (map traverse-arcd-ast (index (ast :children))))
      
      # Update self
      (let [child-max (max ;(map |(get $ :x-position-end) (index (ast :children))))
            x-begin (+ 2 child-max)
            x-end (+ x-begin 1 (length l) 3)
            y-main (let [x (filter |($ :main) (index (ast :children)))]
                     (if (empty? x)
                       (mean (map |($ :y-position) (index (ast :children))))
                       ((first x) :y-position)))] 
        (-> ast
            (put :x-position-max-child child-max)
            (put :x-position-begin x-begin)
            (put :x-position-label (+ child-max 4))
            (put :x-position-end x-end)
            (put :y-position y-main))))
    
    ################## Node ##################
    {:type :node}
    (do (set (ast :children)
             (map traverse-arcd-ast (ast :children)))
        
        # Get largest values from children
        (var max-x (max ;(map |(get $ :x-position-end) (ast :children)))) 
        (var max-label (max ;(map |(get $ :x-position-label) (ast :children))))
        (var longest-label (max ;(map |(length (get $ :label)) (ast :children))))
        (var y-main (let [x (filter |($ :main) (index (ast :children)))]
                      (if (empty? x)
                        (mean (map |($ :y-position) (index (ast :children))))
                        ((first x) :y-position))))
          
        # Update children to all match largest child values
        (each child (ast :children)
          (set (child :x-position-end) max-x)
          (let [prefix (string (if-let [x (child :leaf)]
                                 (string/format "%2d" x) "") " <─")
                suffix (string (child :label)
                               (string/repeat "─" (- longest-label (length (child :label))))
                               (if (child :main) "─*─" "───"))
                midfix (string/repeat "─" (- max-label 
                                             (or (child :x-position-max-child) 0)
                                             (if (= 0 (child :x-position-begin)) 5 4)))]
            (set (child :ascii) (string prefix midfix suffix))))
        
        # Update self
        (-> ast
            (put :x-position-begin (inc max-x))
            (put :x-position-end (inc max-x))
            (put :y-position y-main))))
      
      ################## Return AST ##################
      ast)

(comment (traverse-arcd-ast ast))

# TODO NEXT: Validate full arc is being traversed correctly so far
