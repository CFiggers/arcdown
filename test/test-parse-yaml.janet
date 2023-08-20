(use judge)
(use /src/parse-yaml)

(deftest "test parse-outline" 
  (def sample-yaml
  ```
  - Thing 1 
      - Thing 2 
      - Thing 3 
  - Thing 4
  ```)
  (test (parse-outline sample-yaml) @[{:content "Thing 1" :indent 0 :children @[{:children @[] :content "Thing 2" :indent 4} {:children @[] :content "Thing 3" :indent 4}]} {:content "Thing 4" :indent 0 :children @[]}]))

(deftest "test parse-outline"
  (def sample-yaml
  ```
  - Thing 1 
      - Thing 2 
      - Thing 3 
  - Thing 4
      - Thing 5
          - Thing 6
          - Thing 7 
  - Thing 8
  ```)
  (test (parse-outline sample-yaml) @[{:content "Thing 1" :indent 0 :children @[{:content "Thing 2" :indent 4 :children @[]} {:content "Thing 3" :indent 4 :children @[]}]} {:content "Thing 4" :indent 0 :children @[{:content "Thing 5" :indent 4 :children @[{:children @[] :content "Thing 6" :indent 8} {:children @[] :content "Thing 7" :indent 8}]}]} {:content "Thing 8" :indent 0 :children @[]}]))

(deftest "test parse-outline: complex"
  (def sample-yaml
  ```
  - Thing 1 
      - Thing 2 
      - Thing 3 
  - Thing 4
      - Thing 5
          - Thing 6
          - Thing 7 
  - Thing 8
      - Thing 9
          - Thing 10
      - Thing 11 
  - Thing 12
  - Thing 13
      - Thing 14
          - Thing 15 
              - Thing 16 
  - Thing 17
  ```)
  (test (parse-outline sample-yaml) @[{:content "Thing 1" :indent 0 :children @[{:content "Thing 2" :indent 4 :children @[]} {:content "Thing 3" :indent 4 :children @[]}]} {:content "Thing 4" :indent 0 :children @[{:content "Thing 5" :indent 4 :children @[{:content "Thing 6" :indent 8 :children @[]} {:content "Thing 7" :indent 8 :children @[]}]}]} {:content "Thing 8" :indent 0 :children @[{:content "Thing 9" :indent 4 :children @[{:content "Thing 10" :indent 8 :children @[]}]} {:content "Thing 11" :indent 4 :children @[]}]} {:content "Thing 12" :indent 0 :children @[]} {:content "Thing 13" :indent 0 :children @[{:content "Thing 14" :indent 4 :children @[{:content "Thing 15" :indent 8 :children @[{:content "Thing 16" :indent 12 :children @[]}]}]}]} {:content "Thing 17" :indent 0 :children @[]}]))

(deftest "parse-outline: real arcyaml"
  (def arcyaml
    ```
    - Assertion/Extension
      - Assertion
        - Action/Purpose
          - [1] Action
          - Purpose *
            - Perception/Object
              - [2] Perception *
              - [3] Object
      - Extension
        - Idea/Explanation
          - Idea *
            - Orienter/Content 
              - [4] Orienter
              - Content *
                - Series
                  - And
                    - If/Then
                      - [5] If
                      - [6] Then *
                  - And
                    - If/Then
                      - If
                        - Perception/Object
                          - [7] Perception *
                          - [8] Object
                      - Then *
                        - Perception/Object
                          - [9] Perception *
                          - [10] Object
          - Application
            - Condition/Command
              - Condition
                - Epexegetical
                  - [11] _ *
                  - [12] Epexegesis
              - Command *
                - Action/Result
                  - [13] Action
                  - Result *
                    - Epexegetical
                      - [14] _ *
                      - Epexegesis
                        - Idea/Explanation
                          - [15] Idea *
                          - Explanation
                            - Series
                              - And
                                - Statement/Clarification
                                  - [16] Statement *
                                  - [17] Clarification
                              - And
                                - Concessive
                                  - [18] Concession
                                  - [19] Assertion *       
    ```)
    (test (parse-outline arcyaml) @[{:content "Assertion/Extension" :indent 0 :children @[{:content "Assertion" :indent 2 :children @[{:content "Action/Purpose" :indent 4 :children @[{:content "[1] Action" :indent 6 :children @[]} {:content "Purpose *" :indent 6 :children @[{:content "Perception/Object" :indent 8 :children @[{:content "[2] Perception *" :indent 10 :children @[]} {:content "[3] Object" :indent 10 :children @[]}]}]}]}]} {:content "Extension" :indent 2 :children @[{:content "Idea/Explanation" :indent 4 :children @[{:content "Idea *" :indent 6 :children @[{:content "Orienter/Content" :indent 8 :children @[{:content "[4] Orienter" :indent 10 :children @[]} {:content "Content *" :indent 10 :children @[{:content "Series" :indent 12 :children @[{:content "And" :indent 14 :children @[{:content "If/Then" :indent 16 :children @[{:content "[5] If" :indent 18 :children @[]} {:content "[6] Then *" :indent 18 :children @[]}]}]} {:content "And" :indent 14 :children @[{:content "If/Then" :indent 16 :children @[{:content "If" :indent 18 :children @[{:content "Perception/Object" :indent 20 :children @[{:content "[7] Perception *" :indent 22 :children @[]} {:content "[8] Object" :indent 22 :children @[]}]}]} {:content "Then *" :indent 18 :children @[{:content "Perception/Object" :indent 20 :children @[{:content "[9] Perception *" :indent 22 :children @[]} {:content "[10] Object" :indent 22 :children @[]}]}]}]}]}]}]}]}]} {:content "Application" :indent 6 :children @[{:content "Condition/Command" :indent 8 :children @[{:content "Condition" :indent 10 :children @[{:content "Epexegetical" :indent 12 :children @[{:content "[11] _ *" :indent 14 :children @[]} {:content "[12] Epexegesis" :indent 14 :children @[]}]}]} {:content "Command *" :indent 10 :children @[{:content "Action/Result" :indent 12 :children @[{:content "[13] Action" :indent 14 :children @[]} {:content "Result *" :indent 14 :children @[{:content "Epexegetical" :indent 16 :children @[{:content "[14] _ *" :indent 18 :children @[]} {:content "Epexegesis" :indent 18 :children @[{:content "Idea/Explanation" :indent 20 :children @[{:content "[15] Idea *" :indent 22 :children @[]} {:content "Explanation" :indent 22 :children @[{:content "Series" :indent 24 :children @[{:content "And" :indent 26 :children @[{:content "Statement/Clarification" :indent 28 :children @[{:content "[16] Statement *" :indent 30 :children @[]} {:content "[17] Clarification" :indent 30 :children @[]}]}]} {:content "And" :indent 26 :children @[{:content "Concessive" :indent 28 :children @[{:content "[18] Concession" :indent 30 :children @[]} {:content "[19] Assertion *" :indent 30 :children @[]}]}]}]}]}]}]}]}]}]}]}]}]}]}]}]}]))