# Uncomment to use `janet-lang/spork` helper functions.
# (use spork)

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
              ,|(filter (comp not empty?) (map string/trim (string/split "|" $))))
   :row (/ :raw-row ,|(filter (comp not empty?) (map string/trim (string/split "|" $))))
   :main (* :header (some :row))})

(def arc-text-peg
  ~{:begin-arc-text (* "<!--" :s* "BEGIN:ARCTEXT" :s* "-->" :s*)
    :end-arc-text (* "<!--" :s* "END:ARCTEXT" :s* "-->" :s*)
    :main (/ (* :begin-arc-text (<- (to :end-arc-text)) :end-arc-text) ,|{:arc-text (peg/match md-table-peg $)})})



(def arcdown-peg 
  ~{:front-matter ,front-matter-peg
    :arc-text ,arc-text-peg
    :main (* (? :front-matter) (to :arc-text) :arc-text (some 1))})

(defn main [& args]
  (print "Hello, World!"))