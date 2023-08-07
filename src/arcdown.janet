# Uncomment to use `janet-lang/spork` helper functions.
# (use spork)

(use judge)
(import jdn)

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
    :main (/ (* :begin-arc-text (<- (to :end-arc-text)) :end-arc-text) ,|{:arc-text (peg/match md-table-peg $)})})

(def arc-jdn-peg
  ~{:begin-arc-jdn (* "<!--" :s* "BEGIN:ARCJDN" :s* "-->" :s*)
    :end-arc-jdn (* "<!--" :s* "END:ARCJDN" :s* "-->")
    :codeblock (* "```" (? "janet") :s*)
    :main (/ (* :begin-arc-jdn :codeblock (<- (to :codeblock)) :codeblock :end-arc-jdn) ,|{:arc-jdn (jdn/decode $)})})

(def main-point-peg
  ~{:begin-main-point (* "<!--" :s* "BEGIN:MAINPOINT" :s* "-->" :s*)
    :end-main-point (* :s* "<!--" :s* "END:MAINPOINT" :s* "-->")
    :main (/ (* :begin-main-point (<- (to :end-main-point)) :end-main-point) ,|{:main-point $})})

(def arcdown-peg 
  ~{:front-matter ,front-matter-peg
    :arc-text ,arc-text-peg
    :arc-jdn ,arc-jdn-peg
    :main-point ,main-point-peg
    :main (* (? :front-matter) (some (* (to (+ :arc-text :arc-jdn :main-point)) (+ :arc-text :arc-jdn :main-point))) (some 1))})

(defn main [& args]
  (print "Hello, World!"))