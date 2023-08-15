(use judge)
(use /src/parse-md)

(deftest "nested pegs work" 
  (def test-sub-peg
  ~{:number (/ (<- :d) ,|[$ :sub-number])
    :symbol (/ (<- (set "#$%")) ,|[$ :sub-symbol])
    :main (some (+ :number :symbol))})

(def test-outer-peg
  ~{:sub-peg ,test-sub-peg
    :letter (/ (<- :w) ,|[$ :outer-letter])
    :main (some (+ :sub-peg :letter))})

  (test (peg/match test-outer-peg "123$ab") @[["1" :sub-number] ["2" :sub-number] ["3" :sub-number] ["$" :sub-symbol] ["a" :outer-letter] ["b" :outer-letter]]))

(deftest "front-matter-peg: parses basic front matter"
  (test (first (peg/match front-matter-peg "---\nhellothere: a thing\n thisis: another thing\n---\n")) {:front-matter @{"hellothere" "a thing" "thisis" "another thing"}}))

(deftest "md-table-peg: md-table.txt" 
  (def test-text (slurp "./test/resources/md-table.txt"))
  (test (peg/match md-table-peg test-text) @[@["ESV" "NIV"] @["Thing" "Other Thing"] @["A" "Nothing"]]))

(deftest "md-table-peg: md-table-blanks.txt" 
  (def test-text (slurp "./test/resources/md-table-blanks.txt"))
  (test (peg/match md-table-peg test-text) @[@["ESV" "NIV" "KJV"] @["Thing" "Other Thing" "And"] @["A" "" "The"] @["" "Cell" "End"]]))

(deftest "md-table-peg: arctable.txt"
  (def test-text (slurp "./test/resources/arctable.txt"))
  (test (peg/match md-table-peg test-text) @[@["Row" "ESV" "NIV" "NA28"] @["1" "13 I write these things to you who believe in the name of the Son of God," "13 I write these things to you who believe in the name of the Son of God" "13 \xCE\xA4\xCE\xB1\xE1\xBF\xA6\xCF\x84\xCE\xB1 \xE1\xBC\x94\xCE\xB3\xCF\x81\xCE\xB1\xCF\x88\xCE\xB1 \xE1\xBD\x91\xCE\xBC\xE1\xBF\x96\xCE\xBD, [...] \xCF\x84\xCE\xBF\xE1\xBF\x96\xCF\x82 \xCF\x80\xCE\xB9\xCF\x83\xCF\x84\xCE\xB5\xCF\x8D\xCE\xBF\xCF\x85\xCF\x83\xCE\xB9\xCE\xBD \xCE\xB5\xE1\xBC\xB0\xCF\x82 \xCF\x84\xE1\xBD\xB8 \xE1\xBD\x84\xCE\xBD\xCE\xBF\xCE\xBC\xCE\xB1 \xCF\x84\xCE\xBF\xE1\xBF\xA6 \xCF\x85\xE1\xBC\xB1\xCE\xBF\xE1\xBF\xA6 \xCF\x84\xCE\xBF\xE1\xBF\xA6 \xCE\xB8\xCE\xB5\xCE\xBF\xE1\xBF\xA6."] @["2" "that you may know" "so that you may know" "... \xE1\xBC\xB5\xCE\xBD\xCE\xB1 \xCE\xB5\xE1\xBC\xB0\xCE\xB4\xE1\xBF\x86\xCF\x84\xCE\xB5 [...] ..."] @["3" "that you have eternal life." "that you have eternal life." "... \xE1\xBD\x85\xCF\x84\xCE\xB9 \xCE\xB6\xCF\x89\xE1\xBD\xB4\xCE\xBD \xE1\xBC\x94\xCF\x87\xCE\xB5\xCF\x84\xCE\xB5 \xCE\xB1\xE1\xBC\xB0\xCF\x8E\xCE\xBD\xCE\xB9\xCE\xBF\xCE\xBD, ..."] @["4" "14 And this is the confidence that we have toward him," "14 This is the confidence we have in approaching God:" "14 \xCE\xBA\xCE\xB1\xE1\xBD\xB6 \xCE\xB1\xE1\xBD\x95\xCF\x84\xCE\xB7 \xE1\xBC\x90\xCF\x83\xCF\x84\xE1\xBD\xB6\xCE\xBD \xE1\xBC\xA1 \xCF\x80\xCE\xB1\xCF\x81\xCF\x81\xCE\xB7\xCF\x83\xCE\xAF\xCE\xB1 \xE1\xBC\xA3\xCE\xBD \xE1\xBC\x94\xCF\x87\xCE\xBF\xCE\xBC\xCE\xB5\xCE\xBD \xCF\x80\xCF\x81\xE1\xBD\xB8\xCF\x82 \xCE\xB1\xE1\xBD\x90\xCF\x84\xCF\x8C\xCE\xBD,"] @["5" "that if we ask anything according to his will" "that if we ask anything according to his will," "\xE1\xBD\x85\xCF\x84\xCE\xB9 \xE1\xBC\x90\xCE\xAC\xCE\xBD \xCF\x84\xCE\xB9 \xCE\xB1\xE1\xBC\xB0\xCF\x84\xCF\x8E\xCE\xBC\xCE\xB5\xCE\xB8\xCE\xB1 \xCE\xBA\xCE\xB1\xCF\x84\xE1\xBD\xB0 \xCF\x84\xE1\xBD\xB8 \xCE\xB8\xCE\xAD\xCE\xBB\xCE\xB7\xCE\xBC\xCE\xB1 \xCE\xB1\xE1\xBD\x90\xCF\x84\xCE\xBF\xE1\xBF\xA6"] @["6" "he hears us." "he hears us." "\xE1\xBC\x80\xCE\xBA\xCE\xBF\xCF\x8D\xCE\xB5\xCE\xB9 \xE1\xBC\xA1\xCE\xBC\xE1\xBF\xB6\xCE\xBD."] @["7" "15 And if we know" "15 And if we know" "15 \xCE\xBA\xCE\xB1\xE1\xBD\xB6 \xE1\xBC\x90\xE1\xBD\xB0\xCE\xBD \xCE\xBF\xE1\xBC\xB4\xCE\xB4\xCE\xB1\xCE\xBC\xCE\xB5\xCE\xBD"] @["8" "that he hears us in whatever we ask," "that he hears us\xE2\x80\x94whatever we ask\xE2\x80\x94" "\xE1\xBD\x85\xCF\x84\xCE\xB9 \xE1\xBC\x80\xCE\xBA\xCE\xBF\xCF\x8D\xCE\xB5\xCE\xB9 \xE1\xBC\xA1\xCE\xBC\xE1\xBF\xB6\xCE\xBD \xE1\xBD\x83 \xE1\xBC\x90\xE1\xBD\xB0\xCE\xBD \xCE\xB1\xE1\xBC\xB0\xCF\x84\xCF\x8E\xCE\xBC\xCE\xB5\xCE\xB8\xCE\xB1,"] @["9" "we know" "we know" "\xCE\xBF\xE1\xBC\xB4\xCE\xB4\xCE\xB1\xCE\xBC\xCE\xB5\xCE\xBD"] @["10" "that we have the requests that we have asked of him." "that we have what we asked of him." "\xE1\xBD\x85\xCF\x84\xCE\xB9 \xE1\xBC\x94\xCF\x87\xCE\xBF\xCE\xBC\xCE\xB5\xCE\xBD \xCF\x84\xE1\xBD\xB0 \xCE\xB1\xE1\xBC\xB0\xCF\x84\xCE\xAE\xCE\xBC\xCE\xB1\xCF\x84\xCE\xB1 \xE1\xBC\x83 \xE1\xBE\x90\xCF\x84\xCE\xAE\xCE\xBA\xCE\xB1\xCE\xBC\xCE\xB5\xCE\xBD \xE1\xBC\x80\xCF\x80\xCA\xBC \xCE\xB1\xE1\xBD\x90\xCF\x84\xCE\xBF\xE1\xBF\xA6."] @["11" "16 If anyone sees his brother committing a sin" "16 If you see any brother or sister commit a sin" "16 \xE1\xBC\x98\xCE\xAC\xCE\xBD \xCF\x84\xCE\xB9\xCF\x82 \xE1\xBC\xB4\xCE\xB4\xE1\xBF\x83 \xCF\x84\xE1\xBD\xB8\xCE\xBD \xE1\xBC\x80\xCE\xB4\xCE\xB5\xCE\xBB\xCF\x86\xE1\xBD\xB8\xCE\xBD \xCE\xB1\xE1\xBD\x90\xCF\x84\xCE\xBF\xE1\xBF\xA6 \xE1\xBC\x81\xCE\xBC\xCE\xB1\xCF\x81\xCF\x84\xCE\xAC\xCE\xBD\xCE\xBF\xCE\xBD\xCF\x84\xCE\xB1 \xE1\xBC\x81\xCE\xBC\xCE\xB1\xCF\x81\xCF\x84\xCE\xAF\xCE\xB1\xCE\xBD"] @["12" "not leading to death," "that does not lead to death," "\xCE\xBC\xE1\xBD\xB4 \xCF\x80\xCF\x81\xE1\xBD\xB8\xCF\x82 \xCE\xB8\xCE\xAC\xCE\xBD\xCE\xB1\xCF\x84\xCE\xBF\xCE\xBD,"] @["13" "he shall ask," "you should pray" "\xCE\xB1\xE1\xBC\xB0\xCF\x84\xCE\xAE\xCF\x83\xCE\xB5\xCE\xB9"] @["14" "and God will give him life\xE2\x80\x94" "and God will give them life." "\xCE\xBA\xCE\xB1\xE1\xBD\xB6 \xCE\xB4\xCF\x8E\xCF\x83\xCE\xB5\xCE\xB9 \xCE\xB1\xE1\xBD\x90\xCF\x84\xE1\xBF\xB7 \xCE\xB6\xCF\x89\xCE\xAE\xCE\xBD,"] @["15" "to those who commit sins that do not lead to death." "I refer to those whose sin does not lead to death." "\xCF\x84\xCE\xBF\xE1\xBF\x96\xCF\x82 \xE1\xBC\x81\xCE\xBC\xCE\xB1\xCF\x81\xCF\x84\xCE\xAC\xCE\xBD\xCE\xBF\xCF\x85\xCF\x83\xCE\xB9\xCE\xBD \xCE\xBC\xE1\xBD\xB4 \xCF\x80\xCF\x81\xE1\xBD\xB8\xCF\x82 \xCE\xB8\xCE\xAC\xCE\xBD\xCE\xB1\xCF\x84\xCE\xBF\xCE\xBD."] @["16" "There is sin that leads to death;" "There is a sin that leads to death." "\xE1\xBC\x94\xCF\x83\xCF\x84\xCE\xB9\xCE\xBD \xE1\xBC\x81\xCE\xBC\xCE\xB1\xCF\x81\xCF\x84\xCE\xAF\xCE\xB1 \xCF\x80\xCF\x81\xE1\xBD\xB8\xCF\x82 \xCE\xB8\xCE\xAC\xCE\xBD\xCE\xB1\xCF\x84\xCE\xBF\xCE\xBD\xC2\xB7"] @["17" "I do not say that one should pray for that." "I am not saying that you should pray about that." "\xCE\xBF\xE1\xBD\x90 \xCF\x80\xCE\xB5\xCF\x81\xE1\xBD\xB6 \xE1\xBC\x90\xCE\xBA\xCE\xB5\xCE\xAF\xCE\xBD\xCE\xB7\xCF\x82 \xCE\xBB\xCE\xAD\xCE\xB3\xCF\x89 \xE1\xBC\xB5\xCE\xBD\xCE\xB1 \xE1\xBC\x90\xCF\x81\xCF\x89\xCF\x84\xCE\xAE\xCF\x83\xE1\xBF\x83."] @["18" "17 All wrongdoing is sin," "17 All wrongdoing is sin," "17 \xCF\x80\xE1\xBE\xB6\xCF\x83\xCE\xB1 \xE1\xBC\x80\xCE\xB4\xCE\xB9\xCE\xBA\xCE\xAF\xCE\xB1 \xE1\xBC\x81\xCE\xBC\xCE\xB1\xCF\x81\xCF\x84\xCE\xAF\xCE\xB1 \xE1\xBC\x90\xCF\x83\xCF\x84\xCE\xAF\xCE\xBD,"] @["19" "but there is sin that does not lead to death." "and there is sin that does not lead to death." "\xCE\xBA\xCE\xB1\xE1\xBD\xB6 \xE1\xBC\x94\xCF\x83\xCF\x84\xCE\xB9\xCE\xBD \xE1\xBC\x81\xCE\xBC\xCE\xB1\xCF\x81\xCF\x84\xCE\xAF\xCE\xB1 \xCE\xBF\xE1\xBD\x90 \xCF\x80\xCF\x81\xE1\xBD\xB8\xCF\x82 \xCE\xB8\xCE\xAC\xCE\xBD\xCE\xB1\xCF\x84\xCE\xBF\xCE\xBD."]]))

(deftest "arc-text-peg: parse arctext.txt"
  (def test-text (slurp "./test/resources/arctext.txt"))
  (test (peg/match arc-text-peg test-text) @[{:arc-text @[@["Row" "ESV" "NIV" "NA28"] @["1" "13 I write these things to you who believe in the name of the Son of God," "13 I write these things to you who believe in the name of the Son of God" "13 \xCE\xA4\xCE\xB1\xE1\xBF\xA6\xCF\x84\xCE\xB1 \xE1\xBC\x94\xCE\xB3\xCF\x81\xCE\xB1\xCF\x88\xCE\xB1 \xE1\xBD\x91\xCE\xBC\xE1\xBF\x96\xCE\xBD, [...] \xCF\x84\xCE\xBF\xE1\xBF\x96\xCF\x82 \xCF\x80\xCE\xB9\xCF\x83\xCF\x84\xCE\xB5\xCF\x8D\xCE\xBF\xCF\x85\xCF\x83\xCE\xB9\xCE\xBD \xCE\xB5\xE1\xBC\xB0\xCF\x82 \xCF\x84\xE1\xBD\xB8 \xE1\xBD\x84\xCE\xBD\xCE\xBF\xCE\xBC\xCE\xB1 \xCF\x84\xCE\xBF\xE1\xBF\xA6 \xCF\x85\xE1\xBC\xB1\xCE\xBF\xE1\xBF\xA6 \xCF\x84\xCE\xBF\xE1\xBF\xA6 \xCE\xB8\xCE\xB5\xCE\xBF\xE1\xBF\xA6."] @["2" "that you may know" "so that you may know" "... \xE1\xBC\xB5\xCE\xBD\xCE\xB1 \xCE\xB5\xE1\xBC\xB0\xCE\xB4\xE1\xBF\x86\xCF\x84\xCE\xB5 [...] ..."] @["3" "that you have eternal life." "that you have eternal life." "... \xE1\xBD\x85\xCF\x84\xCE\xB9 \xCE\xB6\xCF\x89\xE1\xBD\xB4\xCE\xBD \xE1\xBC\x94\xCF\x87\xCE\xB5\xCF\x84\xCE\xB5 \xCE\xB1\xE1\xBC\xB0\xCF\x8E\xCE\xBD\xCE\xB9\xCE\xBF\xCE\xBD, ..."] @["4" "14 And this is the confidence that we have toward him," "14 This is the confidence we have in approaching God:" "14 \xCE\xBA\xCE\xB1\xE1\xBD\xB6 \xCE\xB1\xE1\xBD\x95\xCF\x84\xCE\xB7 \xE1\xBC\x90\xCF\x83\xCF\x84\xE1\xBD\xB6\xCE\xBD \xE1\xBC\xA1 \xCF\x80\xCE\xB1\xCF\x81\xCF\x81\xCE\xB7\xCF\x83\xCE\xAF\xCE\xB1 \xE1\xBC\xA3\xCE\xBD \xE1\xBC\x94\xCF\x87\xCE\xBF\xCE\xBC\xCE\xB5\xCE\xBD \xCF\x80\xCF\x81\xE1\xBD\xB8\xCF\x82 \xCE\xB1\xE1\xBD\x90\xCF\x84\xCF\x8C\xCE\xBD,"] @["5" "that if we ask anything according to his will" "that if we ask anything according to his will," "\xE1\xBD\x85\xCF\x84\xCE\xB9 \xE1\xBC\x90\xCE\xAC\xCE\xBD \xCF\x84\xCE\xB9 \xCE\xB1\xE1\xBC\xB0\xCF\x84\xCF\x8E\xCE\xBC\xCE\xB5\xCE\xB8\xCE\xB1 \xCE\xBA\xCE\xB1\xCF\x84\xE1\xBD\xB0 \xCF\x84\xE1\xBD\xB8 \xCE\xB8\xCE\xAD\xCE\xBB\xCE\xB7\xCE\xBC\xCE\xB1 \xCE\xB1\xE1\xBD\x90\xCF\x84\xCE\xBF\xE1\xBF\xA6"] @["6" "he hears us." "he hears us." "\xE1\xBC\x80\xCE\xBA\xCE\xBF\xCF\x8D\xCE\xB5\xCE\xB9 \xE1\xBC\xA1\xCE\xBC\xE1\xBF\xB6\xCE\xBD."] @["7" "15 And if we know" "15 And if we know" "15 \xCE\xBA\xCE\xB1\xE1\xBD\xB6 \xE1\xBC\x90\xE1\xBD\xB0\xCE\xBD \xCE\xBF\xE1\xBC\xB4\xCE\xB4\xCE\xB1\xCE\xBC\xCE\xB5\xCE\xBD"] @["8" "that he hears us in whatever we ask," "that he hears us\xE2\x80\x94whatever we ask\xE2\x80\x94" "\xE1\xBD\x85\xCF\x84\xCE\xB9 \xE1\xBC\x80\xCE\xBA\xCE\xBF\xCF\x8D\xCE\xB5\xCE\xB9 \xE1\xBC\xA1\xCE\xBC\xE1\xBF\xB6\xCE\xBD \xE1\xBD\x83 \xE1\xBC\x90\xE1\xBD\xB0\xCE\xBD \xCE\xB1\xE1\xBC\xB0\xCF\x84\xCF\x8E\xCE\xBC\xCE\xB5\xCE\xB8\xCE\xB1,"] @["9" "we know" "we know" "\xCE\xBF\xE1\xBC\xB4\xCE\xB4\xCE\xB1\xCE\xBC\xCE\xB5\xCE\xBD"] @["10" "that we have the requests that we have asked of him." "that we have what we asked of him." "\xE1\xBD\x85\xCF\x84\xCE\xB9 \xE1\xBC\x94\xCF\x87\xCE\xBF\xCE\xBC\xCE\xB5\xCE\xBD \xCF\x84\xE1\xBD\xB0 \xCE\xB1\xE1\xBC\xB0\xCF\x84\xCE\xAE\xCE\xBC\xCE\xB1\xCF\x84\xCE\xB1 \xE1\xBC\x83 \xE1\xBE\x90\xCF\x84\xCE\xAE\xCE\xBA\xCE\xB1\xCE\xBC\xCE\xB5\xCE\xBD \xE1\xBC\x80\xCF\x80\xCA\xBC \xCE\xB1\xE1\xBD\x90\xCF\x84\xCE\xBF\xE1\xBF\xA6."] @["11" "16 If anyone sees his brother committing a sin" "16 If you see any brother or sister commit a sin" "16 \xE1\xBC\x98\xCE\xAC\xCE\xBD \xCF\x84\xCE\xB9\xCF\x82 \xE1\xBC\xB4\xCE\xB4\xE1\xBF\x83 \xCF\x84\xE1\xBD\xB8\xCE\xBD \xE1\xBC\x80\xCE\xB4\xCE\xB5\xCE\xBB\xCF\x86\xE1\xBD\xB8\xCE\xBD \xCE\xB1\xE1\xBD\x90\xCF\x84\xCE\xBF\xE1\xBF\xA6 \xE1\xBC\x81\xCE\xBC\xCE\xB1\xCF\x81\xCF\x84\xCE\xAC\xCE\xBD\xCE\xBF\xCE\xBD\xCF\x84\xCE\xB1 \xE1\xBC\x81\xCE\xBC\xCE\xB1\xCF\x81\xCF\x84\xCE\xAF\xCE\xB1\xCE\xBD"] @["12" "not leading to death," "that does not lead to death," "\xCE\xBC\xE1\xBD\xB4 \xCF\x80\xCF\x81\xE1\xBD\xB8\xCF\x82 \xCE\xB8\xCE\xAC\xCE\xBD\xCE\xB1\xCF\x84\xCE\xBF\xCE\xBD,"] @["13" "he shall ask," "you should pray" "\xCE\xB1\xE1\xBC\xB0\xCF\x84\xCE\xAE\xCF\x83\xCE\xB5\xCE\xB9"] @["14" "and God will give him life\xE2\x80\x94" "and God will give them life." "\xCE\xBA\xCE\xB1\xE1\xBD\xB6 \xCE\xB4\xCF\x8E\xCF\x83\xCE\xB5\xCE\xB9 \xCE\xB1\xE1\xBD\x90\xCF\x84\xE1\xBF\xB7 \xCE\xB6\xCF\x89\xCE\xAE\xCE\xBD,"] @["15" "to those who commit sins that do not lead to death." "I refer to those whose sin does not lead to death." "\xCF\x84\xCE\xBF\xE1\xBF\x96\xCF\x82 \xE1\xBC\x81\xCE\xBC\xCE\xB1\xCF\x81\xCF\x84\xCE\xAC\xCE\xBD\xCE\xBF\xCF\x85\xCF\x83\xCE\xB9\xCE\xBD \xCE\xBC\xE1\xBD\xB4 \xCF\x80\xCF\x81\xE1\xBD\xB8\xCF\x82 \xCE\xB8\xCE\xAC\xCE\xBD\xCE\xB1\xCF\x84\xCE\xBF\xCE\xBD."] @["16" "There is sin that leads to death;" "There is a sin that leads to death." "\xE1\xBC\x94\xCF\x83\xCF\x84\xCE\xB9\xCE\xBD \xE1\xBC\x81\xCE\xBC\xCE\xB1\xCF\x81\xCF\x84\xCE\xAF\xCE\xB1 \xCF\x80\xCF\x81\xE1\xBD\xB8\xCF\x82 \xCE\xB8\xCE\xAC\xCE\xBD\xCE\xB1\xCF\x84\xCE\xBF\xCE\xBD\xC2\xB7"] @["17" "I do not say that one should pray for that." "I am not saying that you should pray about that." "\xCE\xBF\xE1\xBD\x90 \xCF\x80\xCE\xB5\xCF\x81\xE1\xBD\xB6 \xE1\xBC\x90\xCE\xBA\xCE\xB5\xCE\xAF\xCE\xBD\xCE\xB7\xCF\x82 \xCE\xBB\xCE\xAD\xCE\xB3\xCF\x89 \xE1\xBC\xB5\xCE\xBD\xCE\xB1 \xE1\xBC\x90\xCF\x81\xCF\x89\xCF\x84\xCE\xAE\xCF\x83\xE1\xBF\x83."] @["18" "17 All wrongdoing is sin," "17 All wrongdoing is sin," "17 \xCF\x80\xE1\xBE\xB6\xCF\x83\xCE\xB1 \xE1\xBC\x80\xCE\xB4\xCE\xB9\xCE\xBA\xCE\xAF\xCE\xB1 \xE1\xBC\x81\xCE\xBC\xCE\xB1\xCF\x81\xCF\x84\xCE\xAF\xCE\xB1 \xE1\xBC\x90\xCF\x83\xCF\x84\xCE\xAF\xCE\xBD,"] @["19" "but there is sin that does not lead to death." "and there is sin that does not lead to death." "\xCE\xBA\xCE\xB1\xE1\xBD\xB6 \xE1\xBC\x94\xCF\x83\xCF\x84\xCE\xB9\xCE\xBD \xE1\xBC\x81\xCE\xBC\xCE\xB1\xCF\x81\xCF\x84\xCE\xAF\xCE\xB1 \xCE\xBF\xE1\xBD\x90 \xCF\x80\xCF\x81\xE1\xBD\xB8\xCF\x82 \xCE\xB8\xCE\xAC\xCE\xBD\xCE\xB1\xCF\x84\xCE\xBF\xCE\xBD."]]}]))

(deftest "arc-jdn-peg: parses arcjdn.txt"
  (def test-text (slurp "./test/resources/arcjdn.txt"))
  (test (peg/match arc-jdn-peg test-text) @[{:arc-jdn [:Series [["And" [:Action/Purpose [["Action" {:leaf 1}] ["Purpose" {:main true} [:Perception/Object [["Perception" {:leaf 2 :main true}] ["Object" {:leaf 3}]]]]]]] ["And" [:Assertion/Application [["Assertion" {:main true} [:Orienter/Content [["Orienter" {:leaf 4}] ["Content" {:main true} [:Series [["And" [:If/Then [["If" {:leaf 5}] ["Then" {:leaf 6 :main true}]]]] ["And" [:If/Then [["If" [:Perception/Object [["Perception" {:leaf 7 :main true}] ["Object" {:leaf 8}]]]] ["Then" {:main true} [:Perception/Object [["Perception" {:leaf 9 :main true}] ["Object" {:leaf 10}]]]]]]]]]]]]] ["Application" [:Condition/Command [["Condition" [:Epexegetical [["_" {:leaf 11 :main true}] ["Epexegesis" {:leaf 12}]]]] ["Command" {:main true} [:Action/Result [["Action" {:leaf 13}] ["Result" {:main true} [:Epexegetical [["_" {:leaf 14 :main true}] ["Epexegesis" [:Idea/Explanation [["Idea" {:leaf 15 :main true}] ["Explanation" [:Series [["And" [:Statement/Clarification [["Statement" {:leaf 16 :main true}] ["Clarification" {:leaf 17}]]]] ["And" [:Concessive [["Concession" {:leaf 18}] ["Assertion" {:leaf 19 :main true}]]]]]]]]]]]]]]]]]]]]]]]]}]))

(deftest "arc-down-peg: parse real `.arcd` file"
  (def test-arcdown (slurp "./test/resources/arc.arcd"))
  (test (peg/match arcdown-peg test-arcdown) @[{:front-matter @{"passage" "1 John 5:13-17"}} {:main-point "John's purpose in writing is so that his readers may have confident knowledge of their eternal acceptance before God\xE2\x80\x94a confident knowledge which extends confidence to their prayers, even prayers for restored life in the aftermath of a brother or sister's sin."} {:arc-text @[@["Row" "ESV" "NIV" "NA28"] @["1" "13 I write these things to you who believe in the name of the Son of God," "13 I write these things to you who believe in the name of the Son of God" "13 \xCE\xA4\xCE\xB1\xE1\xBF\xA6\xCF\x84\xCE\xB1 \xE1\xBC\x94\xCE\xB3\xCF\x81\xCE\xB1\xCF\x88\xCE\xB1 \xE1\xBD\x91\xCE\xBC\xE1\xBF\x96\xCE\xBD, [...] \xCF\x84\xCE\xBF\xE1\xBF\x96\xCF\x82 \xCF\x80\xCE\xB9\xCF\x83\xCF\x84\xCE\xB5\xCF\x8D\xCE\xBF\xCF\x85\xCF\x83\xCE\xB9\xCE\xBD \xCE\xB5\xE1\xBC\xB0\xCF\x82 \xCF\x84\xE1\xBD\xB8 \xE1\xBD\x84\xCE\xBD\xCE\xBF\xCE\xBC\xCE\xB1 \xCF\x84\xCE\xBF\xE1\xBF\xA6 \xCF\x85\xE1\xBC\xB1\xCE\xBF\xE1\xBF\xA6 \xCF\x84\xCE\xBF\xE1\xBF\xA6 \xCE\xB8\xCE\xB5\xCE\xBF\xE1\xBF\xA6."] @["2" "that you may know" "so that you may know" "... \xE1\xBC\xB5\xCE\xBD\xCE\xB1 \xCE\xB5\xE1\xBC\xB0\xCE\xB4\xE1\xBF\x86\xCF\x84\xCE\xB5 [...] ..."] @["3" "that you have eternal life." "that you have eternal life." "... \xE1\xBD\x85\xCF\x84\xCE\xB9 \xCE\xB6\xCF\x89\xE1\xBD\xB4\xCE\xBD \xE1\xBC\x94\xCF\x87\xCE\xB5\xCF\x84\xCE\xB5 \xCE\xB1\xE1\xBC\xB0\xCF\x8E\xCE\xBD\xCE\xB9\xCE\xBF\xCE\xBD, ..."] @["4" "14 And this is the confidence that we have toward him," "14 This is the confidence we have in approaching God:" "14 \xCE\xBA\xCE\xB1\xE1\xBD\xB6 \xCE\xB1\xE1\xBD\x95\xCF\x84\xCE\xB7 \xE1\xBC\x90\xCF\x83\xCF\x84\xE1\xBD\xB6\xCE\xBD \xE1\xBC\xA1 \xCF\x80\xCE\xB1\xCF\x81\xCF\x81\xCE\xB7\xCF\x83\xCE\xAF\xCE\xB1 \xE1\xBC\xA3\xCE\xBD \xE1\xBC\x94\xCF\x87\xCE\xBF\xCE\xBC\xCE\xB5\xCE\xBD \xCF\x80\xCF\x81\xE1\xBD\xB8\xCF\x82 \xCE\xB1\xE1\xBD\x90\xCF\x84\xCF\x8C\xCE\xBD,"] @["5" "that if we ask anything according to his will" "that if we ask anything according to his will," "\xE1\xBD\x85\xCF\x84\xCE\xB9 \xE1\xBC\x90\xCE\xAC\xCE\xBD \xCF\x84\xCE\xB9 \xCE\xB1\xE1\xBC\xB0\xCF\x84\xCF\x8E\xCE\xBC\xCE\xB5\xCE\xB8\xCE\xB1 \xCE\xBA\xCE\xB1\xCF\x84\xE1\xBD\xB0 \xCF\x84\xE1\xBD\xB8 \xCE\xB8\xCE\xAD\xCE\xBB\xCE\xB7\xCE\xBC\xCE\xB1 \xCE\xB1\xE1\xBD\x90\xCF\x84\xCE\xBF\xE1\xBF\xA6"] @["6" "he hears us." "he hears us." "\xE1\xBC\x80\xCE\xBA\xCE\xBF\xCF\x8D\xCE\xB5\xCE\xB9 \xE1\xBC\xA1\xCE\xBC\xE1\xBF\xB6\xCE\xBD."] @["7" "15 And if we know" "15 And if we know" "15 \xCE\xBA\xCE\xB1\xE1\xBD\xB6 \xE1\xBC\x90\xE1\xBD\xB0\xCE\xBD \xCE\xBF\xE1\xBC\xB4\xCE\xB4\xCE\xB1\xCE\xBC\xCE\xB5\xCE\xBD"] @["8" "that he hears us in whatever we ask," "that he hears us\xE2\x80\x94whatever we ask\xE2\x80\x94" "\xE1\xBD\x85\xCF\x84\xCE\xB9 \xE1\xBC\x80\xCE\xBA\xCE\xBF\xCF\x8D\xCE\xB5\xCE\xB9 \xE1\xBC\xA1\xCE\xBC\xE1\xBF\xB6\xCE\xBD \xE1\xBD\x83 \xE1\xBC\x90\xE1\xBD\xB0\xCE\xBD \xCE\xB1\xE1\xBC\xB0\xCF\x84\xCF\x8E\xCE\xBC\xCE\xB5\xCE\xB8\xCE\xB1,"] @["9" "we know" "we know" "\xCE\xBF\xE1\xBC\xB4\xCE\xB4\xCE\xB1\xCE\xBC\xCE\xB5\xCE\xBD"] @["10" "that we have the requests that we have asked of him." "that we have what we asked of him." "\xE1\xBD\x85\xCF\x84\xCE\xB9 \xE1\xBC\x94\xCF\x87\xCE\xBF\xCE\xBC\xCE\xB5\xCE\xBD \xCF\x84\xE1\xBD\xB0 \xCE\xB1\xE1\xBC\xB0\xCF\x84\xCE\xAE\xCE\xBC\xCE\xB1\xCF\x84\xCE\xB1 \xE1\xBC\x83 \xE1\xBE\x90\xCF\x84\xCE\xAE\xCE\xBA\xCE\xB1\xCE\xBC\xCE\xB5\xCE\xBD \xE1\xBC\x80\xCF\x80\xCA\xBC \xCE\xB1\xE1\xBD\x90\xCF\x84\xCE\xBF\xE1\xBF\xA6."] @["11" "16 If anyone sees his brother committing a sin" "16 If you see any brother or sister commit a sin" "16 \xE1\xBC\x98\xCE\xAC\xCE\xBD \xCF\x84\xCE\xB9\xCF\x82 \xE1\xBC\xB4\xCE\xB4\xE1\xBF\x83 \xCF\x84\xE1\xBD\xB8\xCE\xBD \xE1\xBC\x80\xCE\xB4\xCE\xB5\xCE\xBB\xCF\x86\xE1\xBD\xB8\xCE\xBD \xCE\xB1\xE1\xBD\x90\xCF\x84\xCE\xBF\xE1\xBF\xA6 \xE1\xBC\x81\xCE\xBC\xCE\xB1\xCF\x81\xCF\x84\xCE\xAC\xCE\xBD\xCE\xBF\xCE\xBD\xCF\x84\xCE\xB1 \xE1\xBC\x81\xCE\xBC\xCE\xB1\xCF\x81\xCF\x84\xCE\xAF\xCE\xB1\xCE\xBD"] @["12" "not leading to death," "that does not lead to death," "\xCE\xBC\xE1\xBD\xB4 \xCF\x80\xCF\x81\xE1\xBD\xB8\xCF\x82 \xCE\xB8\xCE\xAC\xCE\xBD\xCE\xB1\xCF\x84\xCE\xBF\xCE\xBD,"] @["13" "he shall ask," "you should pray" "\xCE\xB1\xE1\xBC\xB0\xCF\x84\xCE\xAE\xCF\x83\xCE\xB5\xCE\xB9"] @["14" "and God will give him life\xE2\x80\x94" "and God will give them life." "\xCE\xBA\xCE\xB1\xE1\xBD\xB6 \xCE\xB4\xCF\x8E\xCF\x83\xCE\xB5\xCE\xB9 \xCE\xB1\xE1\xBD\x90\xCF\x84\xE1\xBF\xB7 \xCE\xB6\xCF\x89\xCE\xAE\xCE\xBD,"] @["15" "to those who commit sins that do not lead to death." "I refer to those whose sin does not lead to death." "\xCF\x84\xCE\xBF\xE1\xBF\x96\xCF\x82 \xE1\xBC\x81\xCE\xBC\xCE\xB1\xCF\x81\xCF\x84\xCE\xAC\xCE\xBD\xCE\xBF\xCF\x85\xCF\x83\xCE\xB9\xCE\xBD \xCE\xBC\xE1\xBD\xB4 \xCF\x80\xCF\x81\xE1\xBD\xB8\xCF\x82 \xCE\xB8\xCE\xAC\xCE\xBD\xCE\xB1\xCF\x84\xCE\xBF\xCE\xBD."] @["16" "There is sin that leads to death;" "There is a sin that leads to death." "\xE1\xBC\x94\xCF\x83\xCF\x84\xCE\xB9\xCE\xBD \xE1\xBC\x81\xCE\xBC\xCE\xB1\xCF\x81\xCF\x84\xCE\xAF\xCE\xB1 \xCF\x80\xCF\x81\xE1\xBD\xB8\xCF\x82 \xCE\xB8\xCE\xAC\xCE\xBD\xCE\xB1\xCF\x84\xCE\xBF\xCE\xBD\xC2\xB7"] @["17" "I do not say that one should pray for that." "I am not saying that you should pray about that." "\xCE\xBF\xE1\xBD\x90 \xCF\x80\xCE\xB5\xCF\x81\xE1\xBD\xB6 \xE1\xBC\x90\xCE\xBA\xCE\xB5\xCE\xAF\xCE\xBD\xCE\xB7\xCF\x82 \xCE\xBB\xCE\xAD\xCE\xB3\xCF\x89 \xE1\xBC\xB5\xCE\xBD\xCE\xB1 \xE1\xBC\x90\xCF\x81\xCF\x89\xCF\x84\xCE\xAE\xCF\x83\xE1\xBF\x83."] @["18" "17 All wrongdoing is sin," "17 All wrongdoing is sin," "17 \xCF\x80\xE1\xBE\xB6\xCF\x83\xCE\xB1 \xE1\xBC\x80\xCE\xB4\xCE\xB9\xCE\xBA\xCE\xAF\xCE\xB1 \xE1\xBC\x81\xCE\xBC\xCE\xB1\xCF\x81\xCF\x84\xCE\xAF\xCE\xB1 \xE1\xBC\x90\xCF\x83\xCF\x84\xCE\xAF\xCE\xBD,"] @["19" "but there is sin that does not lead to death." "and there is sin that does not lead to death." "\xCE\xBA\xCE\xB1\xE1\xBD\xB6 \xE1\xBC\x94\xCF\x83\xCF\x84\xCE\xB9\xCE\xBD \xE1\xBC\x81\xCE\xBC\xCE\xB1\xCF\x81\xCF\x84\xCE\xAF\xCE\xB1 \xCE\xBF\xE1\xBD\x90 \xCF\x80\xCF\x81\xE1\xBD\xB8\xCF\x82 \xCE\xB8\xCE\xAC\xCE\xBD\xCE\xB1\xCF\x84\xCE\xBF\xCE\xBD."]]} {:arc-jdn [:Assertion/Extension [["Assertion" {:main true} [:Action/Purpose [["Action" {:leaf 1}] ["Purpose" {:main true} [:Perception/Object [["Perception" {:leaf 2 :main true}] ["Object" {:leaf 3}]]]]]]] ["Extension" [:Assertion/Application [["Assertion" {:main true} [:Orienter/Content [["Orienter" {:leaf 4}] ["Content" {:main true} [:Series [["And" [:If/Then [["If" {:leaf 5}] ["Then" {:leaf 6 :main true}]]]] ["And" [:If/Then [["If" [:Perception/Object [["Perception" {:leaf 7 :main true}] ["Object" {:leaf 8}]]]] ["Then" {:main true} [:Perception/Object [["Perception" {:leaf 9 :main true}] ["Object" {:leaf 10}]]]]]]]]]]]]] ["Application" [:Condition/Command [["Condition" [:Epexegetical [["_" {:leaf 11 :main true}] ["Epexegesis" {:leaf 12}]]]] ["Command" {:main true} [:Action/Result [["Action" {:leaf 13}] ["Result" {:main true} [:Epexegetical [["_" {:leaf 14 :main true}] ["Epexegesis" [:Idea/Explanation [["Idea" {:leaf 15 :main true}] ["Explanation" [:Series [["And" [:Statement/Clarification [["Statement" {:leaf 16 :main true}] ["Clarification" {:leaf 17}]]]] ["And" [:Concessive [["Concession" {:leaf 18}] ["Assertion" {:leaf 19 :main true}]]]]]]]]]]]]]]]]]]]]]]]]}]))

(deftest "super-simple"
  (def super-simple-arc-hiccup ["Thing" {:main 1 :leaf 1}])
  (test (hiccup-to-ast super-simple-arc-hiccup) @{:type :branch :label "Thing" :leaf 1 :main 1}))

(deftest "less-simple"
  (def less-simple-arc-hiccup [:Negative/Positive [["Negative" {:leaf 2}] ["Positive" {:main 1 :leaf 3}]]])
  (test (hiccup-to-ast less-simple-arc-hiccup) @{:type :node :kind :Negative/Positive :children @[@{:type :branch :label "Negative" :leaf 2} @{:type :branch :label "Positive" :leaf 3 :main 1}]}))

(deftest "simple"
  (def simple-arc-hiccup [:Idea/Explanation [["Idea" {:main 1 :leaf 1}] ["Explanation" [:Negative/Positive [["Negative" {:leaf 2}] ["Positive" {:main 1 :leaf 3}]]]]]])
  (test (hiccup-to-ast simple-arc-hiccup) @{:kind :Idea/Explanation :type :node :children @[@{:label "Idea" :leaf 1 :main 1 :type :branch} @{:label "Explanation" :type :branch :children @[@{:kind :Negative/Positive :type :node :children @[@{:label "Negative" :leaf 2 :type :branch} @{:label "Positive" :leaf 3 :main 1 :type :branch}]}]}]}))

(deftest "an error"
  (def simple-arc-hiccup [:Idea/Explanation [["Idea" {:main 1 :leaf 1}] ["Explanation" [:Negative/Positive [["Negative" {:leaf 2}] ["Positive" {:main 1 :leaf 3}] "this causes an error"]]]]])
  (test (hiccup-to-ast simple-arc-hiccup) @{:kind :Idea/Explanation :type :node :children @[@{:label "Idea" :leaf 1 :main 1 :type :branch} @{:label "Explanation" :type :branch :children @[@{:kind :Negative/Positive :type :node :children @[[:error [["Negative" {:leaf 2}] ["Positive" {:leaf 3 :main 1}] "this causes an error"]]]}]}]}))

(deftest "sub-sub-arc hiccup"
  (def sub-sub-arc ["Purpose" {:main true} [:Perception/Object [["Perception" {:leaf 2 :main true}] ["Object" {:leaf 3}]]]])
  (test (hiccup-to-ast sub-sub-arc) @{:label "Purpose" :main true :type :branch :children @[@{:kind :Perception/Object :type :node :children @[@{:label "Perception" :leaf 2 :main true :type :branch} @{:label "Object" :leaf 3 :type :branch}]}]}))

(deftest "sub-arc hiccup"
  (def sub-arc ["Assertion" {:main true} [:Action/Purpose [["Action" {:leaf 1}] ["Purpose" {:main true} [:Perception/Object [["Perception" {:leaf 2 :main true}] ["Object" {:leaf 3}]]]]]]])
  (test (hiccup-to-ast sub-arc) @{:label "Assertion" :main true :type :branch :children @[@{:kind :Action/Purpose :type :node :children @[@{:label "Action" :leaf 1 :type :branch} @{:label "Purpose" :main true :type :branch :children @[@{:kind :Perception/Object :type :node :children @[@{:label "Perception" :leaf 2 :main true :type :branch} @{:label "Object" :leaf 3 :type :branch}]}]}]}]}))

(deftest "full arc hiccup"
  (def an-arc-hiccup [:Assertion/Extension [["Assertion" {:main true} [:Action/Purpose [["Action" {:leaf 1}] ["Purpose" {:main true} [:Perception/Object [["Perception" {:leaf 2 :main true}] ["Object" {:leaf 3}]]]]]]] ["Extension" [:Assertion/Application [["Assertion" {:main true} [:Orienter/Content [["Orienter" {:leaf 4}] ["Content" {:main true} [:Series [["And" [:If/Then [["If" {:leaf 5}] ["Then" {:leaf 6 :main true}]]]] ["And" [:If/Then [["If" [:Perception/Object [["Perception" {:leaf 7 :main true}] ["Object" {:leaf 8}]]]] ["Then" {:main true} [:Perception/Object [["Perception" {:leaf 9 :main true}] ["Object" {:leaf 10}]]]]]]]]]]]]] ["Application" [:Condition/Command [["Condition" [:Epexegetical [["_" {:leaf 11 :main true}] ["Epexegesis" {:leaf 12}]]]] ["Command" {:main true} [:Action/Result [["Action" {:leaf 13}] ["Result" {:main true} [:Epexegetical [["_" {:leaf 14 :main true}] ["Epexegesis" [:Idea/Explanation [["Idea" {:leaf 15 :main true}] ["Explanation" [:Series [["And" [:Statement/Clarification [["Statement" {:leaf 16 :main true}] ["Clarification" {:leaf 17}]]]] ["And" [:Concessive [["Concession" {:leaf 18}] ["Assertion" {:leaf 19 :main true}]]]]]]]]]]]]]]]]]]]]]]]])
  (test (hiccup-to-ast an-arc-hiccup) @{:children @[@{:children @[@{:children @[@{:label "Action" :leaf 1 :type :branch} @{:children @[@{:children @[@{:label "Perception" :leaf 2 :main true :type :branch} @{:label "Object" :leaf 3 :type :branch}] :kind :Perception/Object :type :node}] :label "Purpose" :main true :type :branch}] :kind :Action/Purpose :type :node}] :label "Assertion" :main true :type :branch} @{:children @[@{:children @[@{:children @[@{:children @[@{:label "Orienter" :leaf 4 :type :branch} @{:children @[@{:children @[@{:children @[@{:children @[@{:label "If" :leaf 5 :type :branch} @{:label "Then" :leaf 6 :main true :type :branch}] :kind :If/Then :type :node}] :label "And" :type :branch} @{:children @[@{:children @[@{:children @[@{:children @[@{:label "Perception" :leaf 7 :main true :type :branch} @{:label "Object" :leaf 8 :type :branch}] :kind :Perception/Object :type :node}] :label "If" :type :branch} @{:children @[@{:children @[@{:label "Perception" :leaf 9 :main true :type :branch} @{:label "Object" :leaf 10 :type :branch}] :kind :Perception/Object :type :node}] :label "Then" :main true :type :branch}] :kind :If/Then :type :node}] :label "And" :type :branch}] :kind :Series :type :node}] :label "Content" :main true :type :branch}] :kind :Orienter/Content :type :node}] :label "Assertion" :main true :type :branch} @{:children @[@{:children @[@{:children @[@{:children @[@{:label "_" :leaf 11 :main true :type :branch} @{:label "Epexegesis" :leaf 12 :type :branch}] :kind :Epexegetical :type :node}] :label "Condition" :type :branch} @{:children @[@{:children @[@{:label "Action" :leaf 13 :type :branch} @{:children @[@{:children @[@{:label "_" :leaf 14 :main true :type :branch} @{:children @[@{:children @[@{:label "Idea" :leaf 15 :main true :type :branch} @{:children @[@{:children @[@{:children @[@{:children @[@{:label "Statement" :leaf 16 :main true :type :branch} @{:label "Clarification" :leaf 17 :type :branch}] :kind :Statement/Clarification :type :node}] :label "And" :type :branch} @{:children @[@{:children @[@{:label "Concession" :leaf 18 :type :branch} @{:label "Assertion" :leaf 19 :main true :type :branch}] :kind :Concessive :type :node}] :label "And" :type :branch}] :kind :Series :type :node}] :label "Explanation" :type :branch}] :kind :Idea/Explanation :type :node}] :label "Epexegesis" :type :branch}] :kind :Epexegetical :type :node}] :label "Result" :main true :type :branch}] :kind :Action/Result :type :node}] :label "Command" :main true :type :branch}] :kind :Condition/Command :type :node}] :label "Application" :type :branch}] :kind :Assertion/Application :type :node}] :label "Extension" :type :branch}] :kind :Assertion/Extension :type :node}))

(deftest "parse a full file"
  (def arcd-file (slurp "./test/resources/arc.arcd"))
  (test (parse-arcd-file arcd-file) @{:arc-jdn @{:children @[@{:children @[@{:children @[@{:label "Action" :leaf 1 :type :branch} @{:children @[@{:children @[@{:label "Perception" :leaf 2 :main true :type :branch} @{:label "Object" :leaf 3 :type :branch}] :kind :Perception/Object :type :node}] :label "Purpose" :main true :type :branch}] :kind :Action/Purpose :type :node}] :label "Assertion" :main true :type :branch} @{:children @[@{:children @[@{:children @[@{:children @[@{:label "Orienter" :leaf 4 :type :branch} @{:children @[@{:children @[@{:children @[@{:children @[@{:label "If" :leaf 5 :type :branch} @{:label "Then" :leaf 6 :main true :type :branch}] :kind :If/Then :type :node}] :label "And" :type :branch} @{:children @[@{:children @[@{:children @[@{:children @[@{:label "Perception" :leaf 7 :main true :type :branch} @{:label "Object" :leaf 8 :type :branch}] :kind :Perception/Object :type :node}] :label "If" :type :branch} @{:children @[@{:children @[@{:label "Perception" :leaf 9 :main true :type :branch} @{:label "Object" :leaf 10 :type :branch}] :kind :Perception/Object :type :node}] :label "Then" :main true :type :branch}] :kind :If/Then :type :node}] :label "And" :type :branch}] :kind :Series :type :node}] :label "Content" :main true :type :branch}] :kind :Orienter/Content :type :node}] :label "Assertion" :main true :type :branch} @{:children @[@{:children @[@{:children @[@{:children @[@{:label "_" :leaf 11 :main true :type :branch} @{:label "Epexegesis" :leaf 12 :type :branch}] :kind :Epexegetical :type :node}] :label "Condition" :type :branch} @{:children @[@{:children @[@{:label "Action" :leaf 13 :type :branch} @{:children @[@{:children @[@{:label "_" :leaf 14 :main true :type :branch} @{:children @[@{:children @[@{:label "Idea" :leaf 15 :main true :type :branch} @{:children @[@{:children @[@{:children @[@{:children @[@{:label "Statement" :leaf 16 :main true :type :branch} @{:label "Clarification" :leaf 17 :type :branch}] :kind :Statement/Clarification :type :node}] :label "And" :type :branch} @{:children @[@{:children @[@{:label "Concession" :leaf 18 :type :branch} @{:label "Assertion" :leaf 19 :main true :type :branch}] :kind :Concessive :type :node}] :label "And" :type :branch}] :kind :Series :type :node}] :label "Explanation" :type :branch}] :kind :Idea/Explanation :type :node}] :label "Epexegesis" :type :branch}] :kind :Epexegetical :type :node}] :label "Result" :main true :type :branch}] :kind :Action/Result :type :node}] :label "Command" :main true :type :branch}] :kind :Condition/Command :type :node}] :label "Application" :type :branch}] :kind :Assertion/Application :type :node}] :label "Extension" :type :branch}] :kind :Assertion/Extension :type :node} :arc-text @[@["Row" "ESV" "NIV" "NA28"] @["1" "13 I write these things to you who believe in the name of the Son of God," "13 I write these things to you who believe in the name of the Son of God" "13 \xCE\xA4\xCE\xB1\xE1\xBF\xA6\xCF\x84\xCE\xB1 \xE1\xBC\x94\xCE\xB3\xCF\x81\xCE\xB1\xCF\x88\xCE\xB1 \xE1\xBD\x91\xCE\xBC\xE1\xBF\x96\xCE\xBD, [...] \xCF\x84\xCE\xBF\xE1\xBF\x96\xCF\x82 \xCF\x80\xCE\xB9\xCF\x83\xCF\x84\xCE\xB5\xCF\x8D\xCE\xBF\xCF\x85\xCF\x83\xCE\xB9\xCE\xBD \xCE\xB5\xE1\xBC\xB0\xCF\x82 \xCF\x84\xE1\xBD\xB8 \xE1\xBD\x84\xCE\xBD\xCE\xBF\xCE\xBC\xCE\xB1 \xCF\x84\xCE\xBF\xE1\xBF\xA6 \xCF\x85\xE1\xBC\xB1\xCE\xBF\xE1\xBF\xA6 \xCF\x84\xCE\xBF\xE1\xBF\xA6 \xCE\xB8\xCE\xB5\xCE\xBF\xE1\xBF\xA6."] @["2" "that you may know" "so that you may know" "... \xE1\xBC\xB5\xCE\xBD\xCE\xB1 \xCE\xB5\xE1\xBC\xB0\xCE\xB4\xE1\xBF\x86\xCF\x84\xCE\xB5 [...] ..."] @["3" "that you have eternal life." "that you have eternal life." "... \xE1\xBD\x85\xCF\x84\xCE\xB9 \xCE\xB6\xCF\x89\xE1\xBD\xB4\xCE\xBD \xE1\xBC\x94\xCF\x87\xCE\xB5\xCF\x84\xCE\xB5 \xCE\xB1\xE1\xBC\xB0\xCF\x8E\xCE\xBD\xCE\xB9\xCE\xBF\xCE\xBD, ..."] @["4" "14 And this is the confidence that we have toward him," "14 This is the confidence we have in approaching God:" "14 \xCE\xBA\xCE\xB1\xE1\xBD\xB6 \xCE\xB1\xE1\xBD\x95\xCF\x84\xCE\xB7 \xE1\xBC\x90\xCF\x83\xCF\x84\xE1\xBD\xB6\xCE\xBD \xE1\xBC\xA1 \xCF\x80\xCE\xB1\xCF\x81\xCF\x81\xCE\xB7\xCF\x83\xCE\xAF\xCE\xB1 \xE1\xBC\xA3\xCE\xBD \xE1\xBC\x94\xCF\x87\xCE\xBF\xCE\xBC\xCE\xB5\xCE\xBD \xCF\x80\xCF\x81\xE1\xBD\xB8\xCF\x82 \xCE\xB1\xE1\xBD\x90\xCF\x84\xCF\x8C\xCE\xBD,"] @["5" "that if we ask anything according to his will" "that if we ask anything according to his will," "\xE1\xBD\x85\xCF\x84\xCE\xB9 \xE1\xBC\x90\xCE\xAC\xCE\xBD \xCF\x84\xCE\xB9 \xCE\xB1\xE1\xBC\xB0\xCF\x84\xCF\x8E\xCE\xBC\xCE\xB5\xCE\xB8\xCE\xB1 \xCE\xBA\xCE\xB1\xCF\x84\xE1\xBD\xB0 \xCF\x84\xE1\xBD\xB8 \xCE\xB8\xCE\xAD\xCE\xBB\xCE\xB7\xCE\xBC\xCE\xB1 \xCE\xB1\xE1\xBD\x90\xCF\x84\xCE\xBF\xE1\xBF\xA6"] @["6" "he hears us." "he hears us." "\xE1\xBC\x80\xCE\xBA\xCE\xBF\xCF\x8D\xCE\xB5\xCE\xB9 \xE1\xBC\xA1\xCE\xBC\xE1\xBF\xB6\xCE\xBD."] @["7" "15 And if we know" "15 And if we know" "15 \xCE\xBA\xCE\xB1\xE1\xBD\xB6 \xE1\xBC\x90\xE1\xBD\xB0\xCE\xBD \xCE\xBF\xE1\xBC\xB4\xCE\xB4\xCE\xB1\xCE\xBC\xCE\xB5\xCE\xBD"] @["8" "that he hears us in whatever we ask," "that he hears us\xE2\x80\x94whatever we ask\xE2\x80\x94" "\xE1\xBD\x85\xCF\x84\xCE\xB9 \xE1\xBC\x80\xCE\xBA\xCE\xBF\xCF\x8D\xCE\xB5\xCE\xB9 \xE1\xBC\xA1\xCE\xBC\xE1\xBF\xB6\xCE\xBD \xE1\xBD\x83 \xE1\xBC\x90\xE1\xBD\xB0\xCE\xBD \xCE\xB1\xE1\xBC\xB0\xCF\x84\xCF\x8E\xCE\xBC\xCE\xB5\xCE\xB8\xCE\xB1,"] @["9" "we know" "we know" "\xCE\xBF\xE1\xBC\xB4\xCE\xB4\xCE\xB1\xCE\xBC\xCE\xB5\xCE\xBD"] @["10" "that we have the requests that we have asked of him." "that we have what we asked of him." "\xE1\xBD\x85\xCF\x84\xCE\xB9 \xE1\xBC\x94\xCF\x87\xCE\xBF\xCE\xBC\xCE\xB5\xCE\xBD \xCF\x84\xE1\xBD\xB0 \xCE\xB1\xE1\xBC\xB0\xCF\x84\xCE\xAE\xCE\xBC\xCE\xB1\xCF\x84\xCE\xB1 \xE1\xBC\x83 \xE1\xBE\x90\xCF\x84\xCE\xAE\xCE\xBA\xCE\xB1\xCE\xBC\xCE\xB5\xCE\xBD \xE1\xBC\x80\xCF\x80\xCA\xBC \xCE\xB1\xE1\xBD\x90\xCF\x84\xCE\xBF\xE1\xBF\xA6."] @["11" "16 If anyone sees his brother committing a sin" "16 If you see any brother or sister commit a sin" "16 \xE1\xBC\x98\xCE\xAC\xCE\xBD \xCF\x84\xCE\xB9\xCF\x82 \xE1\xBC\xB4\xCE\xB4\xE1\xBF\x83 \xCF\x84\xE1\xBD\xB8\xCE\xBD \xE1\xBC\x80\xCE\xB4\xCE\xB5\xCE\xBB\xCF\x86\xE1\xBD\xB8\xCE\xBD \xCE\xB1\xE1\xBD\x90\xCF\x84\xCE\xBF\xE1\xBF\xA6 \xE1\xBC\x81\xCE\xBC\xCE\xB1\xCF\x81\xCF\x84\xCE\xAC\xCE\xBD\xCE\xBF\xCE\xBD\xCF\x84\xCE\xB1 \xE1\xBC\x81\xCE\xBC\xCE\xB1\xCF\x81\xCF\x84\xCE\xAF\xCE\xB1\xCE\xBD"] @["12" "not leading to death," "that does not lead to death," "\xCE\xBC\xE1\xBD\xB4 \xCF\x80\xCF\x81\xE1\xBD\xB8\xCF\x82 \xCE\xB8\xCE\xAC\xCE\xBD\xCE\xB1\xCF\x84\xCE\xBF\xCE\xBD,"] @["13" "he shall ask," "you should pray" "\xCE\xB1\xE1\xBC\xB0\xCF\x84\xCE\xAE\xCF\x83\xCE\xB5\xCE\xB9"] @["14" "and God will give him life\xE2\x80\x94" "and God will give them life." "\xCE\xBA\xCE\xB1\xE1\xBD\xB6 \xCE\xB4\xCF\x8E\xCF\x83\xCE\xB5\xCE\xB9 \xCE\xB1\xE1\xBD\x90\xCF\x84\xE1\xBF\xB7 \xCE\xB6\xCF\x89\xCE\xAE\xCE\xBD,"] @["15" "to those who commit sins that do not lead to death." "I refer to those whose sin does not lead to death." "\xCF\x84\xCE\xBF\xE1\xBF\x96\xCF\x82 \xE1\xBC\x81\xCE\xBC\xCE\xB1\xCF\x81\xCF\x84\xCE\xAC\xCE\xBD\xCE\xBF\xCF\x85\xCF\x83\xCE\xB9\xCE\xBD \xCE\xBC\xE1\xBD\xB4 \xCF\x80\xCF\x81\xE1\xBD\xB8\xCF\x82 \xCE\xB8\xCE\xAC\xCE\xBD\xCE\xB1\xCF\x84\xCE\xBF\xCE\xBD."] @["16" "There is sin that leads to death;" "There is a sin that leads to death." "\xE1\xBC\x94\xCF\x83\xCF\x84\xCE\xB9\xCE\xBD \xE1\xBC\x81\xCE\xBC\xCE\xB1\xCF\x81\xCF\x84\xCE\xAF\xCE\xB1 \xCF\x80\xCF\x81\xE1\xBD\xB8\xCF\x82 \xCE\xB8\xCE\xAC\xCE\xBD\xCE\xB1\xCF\x84\xCE\xBF\xCE\xBD\xC2\xB7"] @["17" "I do not say that one should pray for that." "I am not saying that you should pray about that." "\xCE\xBF\xE1\xBD\x90 \xCF\x80\xCE\xB5\xCF\x81\xE1\xBD\xB6 \xE1\xBC\x90\xCE\xBA\xCE\xB5\xCE\xAF\xCE\xBD\xCE\xB7\xCF\x82 \xCE\xBB\xCE\xAD\xCE\xB3\xCF\x89 \xE1\xBC\xB5\xCE\xBD\xCE\xB1 \xE1\xBC\x90\xCF\x81\xCF\x89\xCF\x84\xCE\xAE\xCF\x83\xE1\xBF\x83."] @["18" "17 All wrongdoing is sin," "17 All wrongdoing is sin," "17 \xCF\x80\xE1\xBE\xB6\xCF\x83\xCE\xB1 \xE1\xBC\x80\xCE\xB4\xCE\xB9\xCE\xBA\xCE\xAF\xCE\xB1 \xE1\xBC\x81\xCE\xBC\xCE\xB1\xCF\x81\xCF\x84\xCE\xAF\xCE\xB1 \xE1\xBC\x90\xCF\x83\xCF\x84\xCE\xAF\xCE\xBD,"] @["19" "but there is sin that does not lead to death." "and there is sin that does not lead to death." "\xCE\xBA\xCE\xB1\xE1\xBD\xB6 \xE1\xBC\x94\xCF\x83\xCF\x84\xCE\xB9\xCE\xBD \xE1\xBC\x81\xCE\xBC\xCE\xB1\xCF\x81\xCF\x84\xCE\xAF\xCE\xB1 \xCE\xBF\xE1\xBD\x90 \xCF\x80\xCF\x81\xE1\xBD\xB8\xCF\x82 \xCE\xB8\xCE\xAC\xCE\xBD\xCE\xB1\xCF\x84\xCE\xBF\xCE\xBD."]] :front-matter @{"passage" "1 John 5:13-17"} :main-point "John's purpose in writing is so that his readers may have confident knowledge of their eternal acceptance before God\xE2\x80\x94a confident knowledge which extends confidence to their prayers, even prayers for restored life in the aftermath of a brother or sister's sin."}))

(deftest "traversing: super-simple" 
  (def super-simple-arc-hiccup ["Thing" {:main 1 :leaf 1}])
  (def super-simple-ast (hiccup-to-ast super-simple-arc-hiccup)) 
  (test (traverse-arcd-ast super-simple-ast) @{:ascii " 1 <─Thing─*─" :label "Thing" :leaf 1 :main 1 :type :branch :x-position-begin 0 :x-position-end 12 :x-position-label 5 :y-position 1}))

(deftest "traversing: less-simple" 
  (def less-simple-arc-hiccup [:Negative/Positive [["Negative" {:leaf 2}] ["Positive" {:main 1 :leaf 3}]]])
  (def less-simple-ast (hiccup-to-ast less-simple-arc-hiccup)) 
  (test (traverse-arcd-ast less-simple-ast) @{:children @[@{:ascii " 2 <─Negative───" :label "Negative" :leaf 2 :type :branch :x-position-begin 0 :x-position-end 15 :x-position-label 5 :y-position 3} @{:ascii " 3 <─Positive─*─" :label "Positive" :leaf 3 :main 1 :type :branch :x-position-begin 0 :x-position-end 15 :x-position-label 5 :y-position 5}] :kind :Negative/Positive :type :node :x-position-begin 16 :x-position-end 16 :y-position 5}))

(comment
  ```
   1 <────────────────Idea────────*─┐
                                    |
   2 <─Negative───┐                 |
                  |                 |
   3 <─Positive─*─┘ <─Explanation───┘
  ```)

(deftest "traversing: simple" 
  (def simple-arc-hiccup [:Idea/Explanation [["Idea" {:main 1 :leaf 1}] ["Explanation" [:Negative/Positive [["Negative" {:leaf 2}] ["Positive" {:main 1 :leaf 3}]]]]]])
  (def simple-ast (hiccup-to-ast simple-arc-hiccup))
  (test (traverse-arcd-ast simple-ast) @{:children @[@{:ascii " 1 <────────────────Idea────────*─" :label "Idea" :leaf 1 :main 1 :type :branch :x-position-begin 0 :x-position-end 33 :x-position-label 5 :y-position 1} @{:ascii " <─Explanation───" :children @[@{:children @[@{:ascii " 2 <─Negative───" :label "Negative" :leaf 2 :type :branch :x-position-begin 0 :x-position-end 15 :x-position-label 5 :y-position 3} @{:ascii " 3 <─Positive─*─" :label "Positive" :leaf 3 :main 1 :type :branch :x-position-begin 0 :x-position-end 15 :x-position-label 5 :y-position 5}] :kind :Negative/Positive :type :node :x-position-begin 16 :x-position-end 16 :y-position 5}] :label "Explanation" :type :branch :x-position-begin 18 :x-position-end 33 :x-position-label 20 :x-position-max-child 16 :y-position 5}] :kind :Idea/Explanation :type :node :x-position-begin 34 :x-position-end 34 :y-position 1}))

(deftest "traversing: full"
  (def an-arc-hiccup [:Assertion/Extension [["Assertion" {:main true} [:Action/Purpose [["Action" {:leaf 1}] ["Purpose" {:main true} [:Perception/Object [["Perception" {:leaf 2 :main true}] ["Object" {:leaf 3}]]]]]]] ["Extension" [:Assertion/Application [["Assertion" {:main true} [:Orienter/Content [["Orienter" {:leaf 4}] ["Content" {:main true} [:Series [["And" [:If/Then [["If" {:leaf 5}] ["Then" {:leaf 6 :main true}]]]] ["And" [:If/Then [["If" [:Perception/Object [["Perception" {:leaf 7 :main true}] ["Object" {:leaf 8}]]]] ["Then" {:main true} [:Perception/Object [["Perception" {:leaf 9 :main true}] ["Object" {:leaf 10}]]]]]]]]]]]]] ["Application" [:Condition/Command [["Condition" [:Epexegetical [["_" {:leaf 11 :main true}] ["Epexegesis" {:leaf 12}]]]] ["Command" {:main true} [:Action/Result [["Action" {:leaf 13}] ["Result" {:main true} [:Epexegetical [["_" {:leaf 14 :main true}] ["Epexegesis" [:Idea/Explanation [["Idea" {:leaf 15 :main true}] ["Explanation" [:Series [["And" [:Statement/Clarification [["Statement" {:leaf 16 :main true}] ["Clarification" {:leaf 17}]]]] ["And" [:Concessive [["Concession" {:leaf 18}] ["Assertion" {:leaf 19 :main true}]]]]]]]]]]]]]]]]]]]]]]]])
  (def arc-ast (hiccup-to-ast an-arc-hiccup))
  (test (traverse-arcd-ast arc-ast)
    @{:kind :Assertion/Extension
      :type :node
      :x-position-begin 127
      :x-position-end 127
      :y-position 3
      :children @[@{:ascii " <────────────────────────────────────────────────────────────────────────────────Assertion─*─"
                    :children @[@{:children @[@{:ascii " 1 <──────────────────Action────"
                                                :label "Action"
                                                :leaf 1
                                                :type :branch
                                                :x-position-begin 0
                                                :x-position-end 31
                                                :x-position-label 5
                                                :y-position 1}
                                              @{:ascii " <─Purpose─*─"
                                                :children @[@{:children @[@{:ascii " 2 <─Perception─*─"
                                                                            :label "Perception"
                                                                            :leaf 2
                                                                            :main true
                                                                            :type :branch
                                                                            :x-position-begin 0
                                                                            :x-position-end 17
                                                                            :x-position-label 5
                                                                            :y-position 3}
                                                                          @{:ascii " 3 <─Object───────"
                                                                            :label "Object"
                                                                            :leaf 3
                                                                            :type :branch
                                                                            :x-position-begin 0
                                                                            :x-position-end 17
                                                                            :x-position-label 5
                                                                            :y-position 5}]
                                                              :kind :Perception/Object
                                                              :type :node
                                                              :x-position-begin 18
                                                              :x-position-end 18
                                                              :y-position 3}]
                                                :label "Purpose"
                                                :main true
                                                :type :branch
                                                :x-position-begin 20
                                                :x-position-end 31
                                                :x-position-label 22
                                                :x-position-max-child 18
                                                :y-position 3}]
                                  :kind :Action/Purpose
                                  :type :node
                                  :x-position-begin 32
                                  :x-position-end 32
                                  :y-position 3}]
                    :label "Assertion"
                    :main true
                    :type :branch
                    :x-position-begin 34
                    :x-position-end 126
                    :x-position-label 36
                    :x-position-max-child 32
                    :y-position 3}
                  @{:ascii " <─Extension───"
                    :children @[@{:children @[@{:ascii " <─────────────────────────────────────────Assertion───*─"
                                                :children @[@{:children @[@{:ascii " 4 <───────────────────────────────────────Orienter───"
                                                                            :label "Orienter"
                                                                            :leaf 4
                                                                            :type :branch
                                                                            :x-position-begin 0
                                                                            :x-position-end 52
                                                                            :x-position-label 5
                                                                            :y-position 7}
                                                                          @{:ascii " <─Content──*─"
                                                                            :children @[@{:children @[@{:ascii " <──────────────────And───"
                                                                                                        :children @[@{:children @[@{:ascii " 5 <─If─────"
                                                                                                                                    :label "If"
                                                                                                                                    :leaf 5
                                                                                                                                    :type :branch
                                                                                                                                    :x-position-begin 0
                                                                                                                                    :x-position-end 11
                                                                                                                                    :x-position-label 5
                                                                                                                                    :y-position 9}
                                                                                                                                  @{:ascii " 6 <─Then─*─"
                                                                                                                                    :label "Then"
                                                                                                                                    :leaf 6
                                                                                                                                    :main true
                                                                                                                                    :type :branch
                                                                                                                                    :x-position-begin 0
                                                                                                                                    :x-position-end 11
                                                                                                                                    :x-position-label 5
                                                                                                                                    :y-position 11}]
                                                                                                                      :kind :If/Then
                                                                                                                      :type :node
                                                                                                                      :x-position-begin 12
                                                                                                                      :x-position-end 12
                                                                                                                      :y-position 11}]
                                                                                                        :label "And"
                                                                                                        :type :branch
                                                                                                        :x-position-begin 14
                                                                                                        :x-position-end 38
                                                                                                        :x-position-label 16
                                                                                                        :x-position-max-child 12
                                                                                                        :y-position 11}
                                                                                                      @{:ascii " <─And───"
                                                                                                        :children @[@{:children @[@{:ascii " <─If─────"
                                                                                                                                    :children @[@{:children @[@{:ascii " 7 <─Perception─*─"
                                                                                                                                                                :label "Perception"
                                                                                                                                                                :leaf 7
                                                                                                                                                                :main true
                                                                                                                                                                :type :branch
                                                                                                                                                                :x-position-begin 0
                                                                                                                                                                :x-position-end 17
                                                                                                                                                                :x-position-label 5
                                                                                                                                                                :y-position 13}
                                                                                                                                                              @{:ascii " 8 <─Object───────"
                                                                                                                                                                :label "Object"
                                                                                                                                                                :leaf 8
                                                                                                                                                                :type :branch
                                                                                                                                                                :x-position-begin 0
                                                                                                                                                                :x-position-end 17
                                                                                                                                                                :x-position-label 5
                                                                                                                                                                :y-position 15}]
                                                                                                                                                  :kind :Perception/Object
                                                                                                                                                  :type :node
                                                                                                                                                  :x-position-begin 18
                                                                                                                                                  :x-position-end 18
                                                                                                                                                  :y-position 13}]
                                                                                                                                    :label "If"
                                                                                                                                    :type :branch
                                                                                                                                    :x-position-begin 20
                                                                                                                                    :x-position-end 28
                                                                                                                                    :x-position-label 22
                                                                                                                                    :x-position-max-child 18
                                                                                                                                    :y-position 13}
                                                                                                                                  @{:ascii " <─Then─*─"
                                                                                                                                    :children @[@{:children @[@{:ascii " 9 <─Perception─*─"
                                                                                                                                                                :label "Perception"
                                                                                                                                                                :leaf 9
                                                                                                                                                                :main true
                                                                                                                                                                :type :branch
                                                                                                                                                                :x-position-begin 0
                                                                                                                                                                :x-position-end 17
                                                                                                                                                                :x-position-label 5
                                                                                                                                                                :y-position 17}
                                                                                                                                                              @{:ascii "10 <─Object───────"
                                                                                                                                                                :label "Object"
                                                                                                                                                                :leaf 10
                                                                                                                                                                :type :branch
                                                                                                                                                                :x-position-begin 0
                                                                                                                                                                :x-position-end 17
                                                                                                                                                                :x-position-label 5
                                                                                                                                                                :y-position 19}]
                                                                                                                                                  :kind :Perception/Object
                                                                                                                                                  :type :node
                                                                                                                                                  :x-position-begin 18
                                                                                                                                                  :x-position-end 18
                                                                                                                                                  :y-position 17}]
                                                                                                                                    :label "Then"
                                                                                                                                    :main true
                                                                                                                                    :type :branch
                                                                                                                                    :x-position-begin 20
                                                                                                                                    :x-position-end 28
                                                                                                                                    :x-position-label 22
                                                                                                                                    :x-position-max-child 18
                                                                                                                                    :y-position 17}]
                                                                                                                      :kind :If/Then
                                                                                                                      :type :node
                                                                                                                      :x-position-begin 29
                                                                                                                      :x-position-end 29
                                                                                                                      :y-position 17}]
                                                                                                        :label "And"
                                                                                                        :type :branch
                                                                                                        :x-position-begin 31
                                                                                                        :x-position-end 38
                                                                                                        :x-position-label 33
                                                                                                        :x-position-max-child 29
                                                                                                        :y-position 17}]
                                                                                          :kind :Series
                                                                                          :type :node
                                                                                          :x-position-begin 39
                                                                                          :x-position-end 39
                                                                                          :y-position 14}]
                                                                            :label "Content"
                                                                            :main true
                                                                            :type :branch
                                                                            :x-position-begin 41
                                                                            :x-position-end 52
                                                                            :x-position-label 43
                                                                            :x-position-max-child 39
                                                                            :y-position 14}]
                                                              :kind :Orienter/Content
                                                              :type :node
                                                              :x-position-begin 53
                                                              :x-position-end 53
                                                              :y-position 14}]
                                                :label "Assertion"
                                                :main true
                                                :type :branch
                                                :x-position-begin 55
                                                :x-position-end 110
                                                :x-position-label 57
                                                :x-position-max-child 53
                                                :y-position 14}
                                              @{:ascii " <─Application───"
                                                :children @[@{:children @[@{:ascii " <──────────────────────────────────────────────────────────────Condition───"
                                                                            :children @[@{:children @[@{:ascii "11 <─_──────────*─"
                                                                                                        :label "_"
                                                                                                        :leaf 11
                                                                                                        :main true
                                                                                                        :type :branch
                                                                                                        :x-position-begin 0
                                                                                                        :x-position-end 17
                                                                                                        :x-position-label 5
                                                                                                        :y-position 21}
                                                                                                      @{:ascii "12 <─Epexegesis───"
                                                                                                        :label "Epexegesis"
                                                                                                        :leaf 12
                                                                                                        :type :branch
                                                                                                        :x-position-begin 0
                                                                                                        :x-position-end 17
                                                                                                        :x-position-label 5
                                                                                                        :y-position 23}]
                                                                                          :kind :Epexegetical
                                                                                          :type :node
                                                                                          :x-position-begin 18
                                                                                          :x-position-end 18
                                                                                          :y-position 21}]
                                                                            :label "Condition"
                                                                            :type :branch
                                                                            :x-position-begin 20
                                                                            :x-position-end 92
                                                                            :x-position-label 22
                                                                            :x-position-max-child 18
                                                                            :y-position 21}
                                                                          @{:ascii " <─Command───*─"
                                                                            :children @[@{:children @[@{:ascii "13 <──────────────────────────────────────────────────────────────────Action───"
                                                                                                        :label "Action"
                                                                                                        :leaf 13
                                                                                                        :type :branch
                                                                                                        :x-position-begin 0
                                                                                                        :x-position-end 78
                                                                                                        :x-position-label 5
                                                                                                        :y-position 25}
                                                                                                      @{:ascii " <─Result─*─"
                                                                                                        :children @[@{:children @[@{:ascii "14 <─────────────────────────────────────────────────_──────────*─"
                                                                                                                                    :label "_"
                                                                                                                                    :leaf 14
                                                                                                                                    :main true
                                                                                                                                    :type :branch
                                                                                                                                    :x-position-begin 0
                                                                                                                                    :x-position-end 65
                                                                                                                                    :x-position-label 5
                                                                                                                                    :y-position 27}
                                                                                                                                  @{:ascii " <─Epexegesis───"
                                                                                                                                    :children @[@{:children @[@{:ascii "15 <───────────────────────────────Idea────────*─"
                                                                                                                                                                :label "Idea"
                                                                                                                                                                :leaf 15
                                                                                                                                                                :main true
                                                                                                                                                                :type :branch
                                                                                                                                                                :x-position-begin 0
                                                                                                                                                                :x-position-end 48
                                                                                                                                                                :x-position-label 5
                                                                                                                                                                :y-position 29}
                                                                                                                                                              @{:ascii " <─Explanation───"
                                                                                                                                                                :children @[@{:children @[@{:ascii " <─And───"
                                                                                                                                                                                            :children @[@{:children @[@{:ascii "16 <─Statement─────*─"
                                                                                                                                                                                                                        :label "Statement"
                                                                                                                                                                                                                        :leaf 16
                                                                                                                                                                                                                        :main true
                                                                                                                                                                                                                        :type :branch
                                                                                                                                                                                                                        :x-position-begin 0
                                                                                                                                                                                                                        :x-position-end 20
                                                                                                                                                                                                                        :x-position-label 5
                                                                                                                                                                                                                        :y-position 31}
                                                                                                                                                                                                                      @{:ascii "17 <─Clarification───"
                                                                                                                                                                                                                        :label "Clarification"
                                                                                                                                                                                                                        :leaf 17
                                                                                                                                                                                                                        :type :branch
                                                                                                                                                                                                                        :x-position-begin 0
                                                                                                                                                                                                                        :x-position-end 20
                                                                                                                                                                                                                        :x-position-label 5
                                                                                                                                                                                                                        :y-position 33}]
                                                                                                                                                                                                          :kind :Statement/Clarification
                                                                                                                                                                                                          :type :node
                                                                                                                                                                                                          :x-position-begin 21
                                                                                                                                                                                                          :x-position-end 21
                                                                                                                                                                                                          :y-position 31}]
                                                                                                                                                                                            :label "And"
                                                                                                                                                                                            :type :branch
                                                                                                                                                                                            :x-position-begin 23
                                                                                                                                                                                            :x-position-end 30
                                                                                                                                                                                            :x-position-label 25
                                                                                                                                                                                            :x-position-max-child 21
                                                                                                                                                                                            :y-position 31}
                                                                                                                                                                                          @{:ascii " <────And───"
                                                                                                                                                                                            :children @[@{:children @[@{:ascii "18 <─Concession───"
                                                                                                                                                                                                                        :label "Concession"
                                                                                                                                                                                                                        :leaf 18
                                                                                                                                                                                                                        :type :branch
                                                                                                                                                                                                                        :x-position-begin 0
                                                                                                                                                                                                                        :x-position-end 17
                                                                                                                                                                                                                        :x-position-label 5
                                                                                                                                                                                                                        :y-position 35}
                                                                                                                                                                                                                      @{:ascii "19 <─Assertion──*─"
                                                                                                                                                                                                                        :label "Assertion"
                                                                                                                                                                                                                        :leaf 19
                                                                                                                                                                                                                        :main true
                                                                                                                                                                                                                        :type :branch
                                                                                                                                                                                                                        :x-position-begin 0
                                                                                                                                                                                                                        :x-position-end 17
                                                                                                                                                                                                                        :x-position-label 5
                                                                                                                                                                                                                        :y-position 37}]
                                                                                                                                                                                                          :kind :Concessive
                                                                                                                                                                                                          :type :node
                                                                                                                                                                                                          :x-position-begin 18
                                                                                                                                                                                                          :x-position-end 18
                                                                                                                                                                                                          :y-position 37}]
                                                                                                                                                                                            :label "And"
                                                                                                                                                                                            :type :branch
                                                                                                                                                                                            :x-position-begin 20
                                                                                                                                                                                            :x-position-end 30
                                                                                                                                                                                            :x-position-label 22
                                                                                                                                                                                            :x-position-max-child 18
                                                                                                                                                                                            :y-position 37}]
                                                                                                                                                                              :kind :Series
                                                                                                                                                                              :type :node
                                                                                                                                                                              :x-position-begin 31
                                                                                                                                                                              :x-position-end 31
                                                                                                                                                                              :y-position 34}]
                                                                                                                                                                :label "Explanation"
                                                                                                                                                                :type :branch
                                                                                                                                                                :x-position-begin 33
                                                                                                                                                                :x-position-end 48
                                                                                                                                                                :x-position-label 35
                                                                                                                                                                :x-position-max-child 31
                                                                                                                                                                :y-position 34}]
                                                                                                                                                  :kind :Idea/Explanation
                                                                                                                                                  :type :node
                                                                                                                                                  :x-position-begin 49
                                                                                                                                                  :x-position-end 49
                                                                                                                                                  :y-position 29}]
                                                                                                                                    :label "Epexegesis"
                                                                                                                                    :type :branch
                                                                                                                                    :x-position-begin 51
                                                                                                                                    :x-position-end 65
                                                                                                                                    :x-position-label 53
                                                                                                                                    :x-position-max-child 49
                                                                                                                                    :y-position 29}]
                                                                                                                      :kind :Epexegetical
                                                                                                                      :type :node
                                                                                                                      :x-position-begin 66
                                                                                                                      :x-position-end 66
                                                                                                                      :y-position 27}]
                                                                                                        :label "Result"
                                                                                                        :main true
                                                                                                        :type :branch
                                                                                                        :x-position-begin 68
                                                                                                        :x-position-end 78
                                                                                                        :x-position-label 70
                                                                                                        :x-position-max-child 66
                                                                                                        :y-position 27}]
                                                                                          :kind :Action/Result
                                                                                          :type :node
                                                                                          :x-position-begin 79
                                                                                          :x-position-end 79
                                                                                          :y-position 27}]
                                                                            :label "Command"
                                                                            :main true
                                                                            :type :branch
                                                                            :x-position-begin 81
                                                                            :x-position-end 92
                                                                            :x-position-label 83
                                                                            :x-position-max-child 79
                                                                            :y-position 27}]
                                                              :kind :Condition/Command
                                                              :type :node
                                                              :x-position-begin 93
                                                              :x-position-end 93
                                                              :y-position 27}]
                                                :label "Application"
                                                :type :branch
                                                :x-position-begin 95
                                                :x-position-end 110
                                                :x-position-label 97
                                                :x-position-max-child 93
                                                :y-position 27}]
                                  :kind :Assertion/Application
                                  :type :node
                                  :x-position-begin 111
                                  :x-position-end 111
                                  :y-position 14}]
                    :label "Extension"
                    :type :branch
                    :x-position-begin 113
                    :x-position-end 126
                    :x-position-label 115
                    :x-position-max-child 111
                    :y-position 14}]}))