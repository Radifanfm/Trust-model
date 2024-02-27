extensions [nw]

breed [Users User]
breed [Tweets Tweet]
breed [Comments Comment]

directed-link-breed [followings following]
directed-link-breed [tweetlinks tweetlink]
directed-link-breed [commentlinks commentlink]
directed-link-breed [sharelinks sharelink]

globals [
  stop-disseminate
  seen-count
  tweet-number
]

Users-own [
  ;variable on the profile page;
  age
  authority
  #followers
  #follows



  ;personality variables;
  opn_value
  con_value
  ext_value
  agr_value
  neu_value

  ;other pers variables;
  knowledge
  psychopathy
  #psychopathy

  ;Trust;
   %Trust
    IdentityFactor
       Age_Factor
         Agei
       Popularity_Factor
         Followersi
         Followersj
       Authority_Factor
         Authority
    BehaviorFactor
       Inf
    RelationFactor
       LocalClustering
       BetweenessCentrality
    FeedbackFactor
    InformationFactor
trustable

  ;;;;;;behavior-based;;;;;;
  users-likes-behavior
  true-likes
  fake-likes
  users-shares-behavior
  true-shares
  fake-shares
  true-discards
  fake-discards



;;users conditions;;
  seen-message?
  seen-fake-message
  tweet-message?
  did-comment?
  did-like?
  seen-fake-message?
  tweet-fake-message?
  ovtrustdone
  ;number-of-faketweets
]

tweets-own [
  ;tweet attributes;
  number-of-photo
  includedpicture
  concept
  references
  fake-news
  Influence
  InfluenceT
  clarification
  tweet-accuracy
  tweet-logic
  tweet-popularity

  ;tweetc conditions;
  number-of-likes
  number-of-comments
  number-of-shares
  number-of-discards

  ;tweetsengagement;
  likes-tweet
  share-tweet
  comment-tweet
  positive-comment-tweet
  negative-comment-tweet
]

comments-own [
  positive-comment
  negative-comment
  clarification-comment
  comment-logic
  comment-accuracy
]

to clear
  clear-all
  ask patches[set pcolor white]
end

to Setup-scale-free-network
  clear-all
  ask patches[set pcolor white]
  set-default-shape Users "person"
  ;; make the initial network of two turtles and an edge
  make-node nobody        ;; first node, unattached
  make-node User 0      ;; second node, attached to first node
  reset-ticks
  go
  variable-setup
end

;;;;;;;;;;;;;;;;;;;;;;;
;;; Setup Network   ;;;
;;;;;;;;;;;;;;;;;;;;;;;

  to go
     ;; new edge is green, old edges are gray
     ask followings [ set color red ]
     repeat #user - 2 [
     make-node find-partner         ;; find partner & use it as attachment
                                    ;; point for new node
     layout]
  end

   ;; used for creating a new node
   to make-node [old-node]
     create-users 1
     [
       set color red
    ;big-5-personality;
    set opn_value random-normal opn opn_std ;48.01 8.95
    set con_value random-normal con con_std ;47.19 11.24
    set ext_value random-normal ext ext_std;51.25 8.81
    set agr_value random-normal agr agr_std ;46.38 9.02
    set neu_value random-normal neu neu_std ;49.73 9.66
       if old-node != nobody
         [ create-following-from old-node [ set color green ]
           ;; position the new node near its partner
           move-to old-node
           fd 8
         ]
     ]
   end

   to-report find-partner
     report [one-of both-ends] of one-of followings
   end


   to layout
     ;; the number 3 here is arbitrary; more repetitions slows down the
     ;; model, but too few gives poor layouts
     repeat 3 [
       ;; the more turtles we have to fit into the same amount of space,
       ;; the smaller the inputs to layout-spring we'll need to use
       let factor sqrt count turtles
       ;; numbers here are arbitrarily chosen for pleasing appearance
       layout-spring turtles followings (1 / factor) (7 / factor) (1 / factor)
       display  ;; for smooth animation
     ]
     ;; don't bump the edges of the world
     let x-offset max [xcor] of turtles + min [xcor] of turtles
     let y-offset max [ycor] of turtles + min [ycor] of turtles
     ;; big jumps look funny, so only adjust a little each time
     set x-offset limit-magnitude x-offset 0.1
     set y-offset limit-magnitude y-offset 0.1
     ask turtles [ setxy (xcor - x-offset / 2) (ycor - y-offset / 2) ]
   end

   to-report limit-magnitude [number limit]
     if number > limit [ report limit ]
     if number < (- limit) [ report (- limit) ]
     report number
   end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Setup Network Done!  ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to Big-5-standards
  set opn 48.01
  set opn_std 8.95
  set con 47.19
  set con_std 11.24
  set ext 51.25
  set ext_std 8.81
  set agr 46.38
  set agr_std 9.02
  set neu 49.73
  set neu_std 9.66
end

to variable-setup
  set stop-disseminate false
  ask users [
    ;interface;
    set size 1.5

    ;variable on the profile page;
    set age random-poisson #age-val
    set authority random-poisson #auth-val

    ;;users conditions;;
    set seen-message? false
    set did-comment? false
    set did-like? false
    set seen-fake-message? false
    set tweet-fake-message? false

    if first-fake-news = 1
     [
        ask users with-max [#followers]
        [
          set psychopathy 1
        ]
     ]

   ;other pers variables;
    random-seed 100 set knowledge random-normal know know_std
    random-seed 100 set #psychopathy random-normal psy psy_std
    ifelse #psychopathy > #psychopathythresh
    [set psychopathy true][set psychopathy false]


   ;Trust;
     set %Trust 0.5
     set tweet-message? false
      set IdentityFactor 0.5
        set Age_Factor 0.5
       set Popularity_Factor 0.5
         set Followersi 0.5
         set Followersj 0.5
       set Authority_Factor 0.5
    set BehaviorFactor 0.5
       set Inf 0.5
    set RelationFactor 0.5
       set LocalClustering 0.5
       set BetweenessCentrality 0.5
    set FeedbackFactor 0.5
    set InformationFactor 0.5
    set #followers count out-following-neighbors

    ;;;;;;;;usersbehaviorfactor;;;;;;
    set users-likes-behavior 0
    set fake-likes 0
    set true-likes 0
    set users-shares-behavior 0
    set true-shares 0
    set fake-shares 0
    set true-discards 0
    set fake-discards 0



    ;;color;;
    if opn_value > con_value
    [
      if opn_value > ext_value
      [
       if opn_value > agr_value
        [
         if opn_value > neu_value
          [
           set color red
           ]
        ]
      ]
    ]
    if con_value > opn_value
    [
      if con_value > ext_value
      [
      if con_value > agr_value
       [
        if con_value > neu_value
          [
          set color blue
          ]
        ]
      ]
    ]
    if ext_value > opn_value
    [
      if ext_value > con_value
      [
       if ext_value > agr_value
        [
          if ext_value > neu_value
          [
           set color yellow
          ]
        ]
      ]
    ]
    if agr_value > opn_value
    [
      if agr_value > con_value
      [
        if agr_value > ext_value
        [
          if agr_value > neu_value
          [
           set color green
          ]
        ]
      ]
    ]
    if neu_value > opn_value
    [
      if neu_value > con_value
      [
        if neu_value > ext_value
        [
          if neu_value > agr_value
          [
          set color orange
          ]
        ]
       ]
      ]
  ]
end


to Start
  response
  fake-news-dissemination
  ;;hatching;;
  if stop-disseminate = false
  [ if tweet-number != #tweet
    [
      ask users
      [
        hatching
      ]
    ]
     following-procedure
  ]

  ;;;trustmodel;;;
  trust-model

;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Interface Changes  ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

ask users
  [
    ifelse seen-message? = true
    [set color blue]
    [set color red]
  ]

  ask tweets
  [
    ifelse fake-news = 1
    [ set color black ]
    [ set color blue ]
    set shape "square" set size 1.5
  ]
  ask tweetlinks
  [ set color blue ]
  ask comments
  [
    set color lime set shape "triangle"
  ]
  ;ask comments with [clar = 1] [set color violet]
  ask commentlinks
  [ set color lime ]
  set seen-count count users with [seen-message?]
  layout
  tick
end

to hatching
if #tweet = 1
  [
   ifelse count users with [opn > #openness] > 0
   [
    if count users with [seen-message?] = 0
    [
      ask n-of 1 users with [opn > #openness] with-max [#followers] with [tweet-message? = false]
      [
        if ext < 30
        [
          ifelse psychopathy = false
          [
            set  tweet-message? true
            hatch-tweets 1
            [
              set fake-news 0
              set number-of-photo 0
              set IncludedPicture 0
              create-tweetlink-from myself
              create-tweetlinks-to other [out-following-neighbors] of myself
              ask [out-following-neighbors] of myself [set seen-message? true]
            ]
            set seen-message? true
            set tweet-number tweet-number + 1
          ]
          [
             set  tweet-fake-message? true
             hatch-tweets 1
            [
              set fake-news 1
              set number-of-photo 0
              set IncludedPicture 0
              create-tweetlink-from myself
              create-tweetlinks-to other [out-following-neighbors] of myself
              ask [out-following-neighbors] of myself [set seen-message? true]
            ]
            set seen-message? true
            set tweet-number tweet-number + 1
          ]
        ]
        if ext >= 30 and ext < 40
        [
          ifelse psychopathy = false
            [
              set  tweet-message? true
              hatch-tweets 1
               [
                 set fake-news 1
                 set number-of-photo 1
                 set IncludedPicture 0.25
                 create-tweetlink-from myself
                 create-tweetlinks-to other [out-following-neighbors] of myself
                 ask [out-following-neighbors] of myself [set seen-message? true]
               ]
              set seen-message? true
              set tweet-number tweet-number + 1
            ]
            [
             set  tweet-fake-message? true
              hatch-tweets 1
               [
                set fake-news 1
                set number-of-photo 0
                set IncludedPicture 0
                create-tweetlink-from myself
                create-tweetlinks-to other [out-following-neighbors] of myself
                ask [out-following-neighbors] of myself [set seen-message? true]
               ]
            set seen-message? true
            set tweet-number tweet-number + 1
           ]
        ]
        if ext >= 40 and ext < 50
        [
          ifelse psychopathy = false
             [
              set  tweet-message? true
              hatch-tweets 1
              [
               set fake-news 0
               set number-of-photo 2
               set IncludedPicture 0.5
               create-tweetlink-from myself
               create-tweetlinks-to other [out-following-neighbors] of myself
               ask [out-following-neighbors] of myself [set seen-message? true]
              ]
          set seen-message? true
          set tweet-number tweet-number + 1
             ]
             [
               set  tweet-fake-message? true
               hatch-tweets 1
                [
                 set fake-news 1
                 set number-of-photo 2
                 set IncludedPicture 0.5
                 create-tweetlink-from myself
                 create-tweetlinks-to other [out-following-neighbors] of myself
                 ask [out-following-neighbors] of myself [set seen-message? true]
                ]
             set seen-message? true
             set tweet-number tweet-number + 1
            ]
           ]

        if ext >= 50 and ext < 60
        [
          ifelse psychopathy = false
             [
              set  tweet-message? true
              hatch-tweets 1
              [
               set fake-news 0
               set number-of-photo 3
               set IncludedPicture 0.75
               create-tweetlink-from myself
               create-tweetlinks-to other [out-following-neighbors] of myself
               ask [out-following-neighbors] of myself [set seen-message? true]
              ]
          set seen-message? true
          set tweet-number tweet-number + 1
             ]
             [
               set  tweet-fake-message? true
               hatch-tweets 1
                 [
                  set fake-news 1
                  set number-of-photo 3
                  set IncludedPicture 0.75
                  create-tweetlink-from myself
                  create-tweetlinks-to other [out-following-neighbors] of myself
                  ask [out-following-neighbors] of myself [set seen-message? true]
                 ]
               set seen-message? true
               set tweet-number tweet-number + 1
             ]
        ]
        if ext >= 60
        [
          ifelse psychopathy = false
              [
               set  tweet-message? true
               hatch-tweets 1
                [
                set fake-news 0
                set number-of-photo 4
                set IncludedPicture 1
                create-tweetlink-from myself
                create-tweetlinks-to other [out-following-neighbors] of myself
                ask [out-following-neighbors] of myself [set seen-message? true]
              ]
          set seen-message? true
          set tweet-number tweet-number + 1
             ]
             [
              set  tweet-fake-message? true
              hatch-tweets 1
               [
               set fake-news 1
               set number-of-photo 4
               set IncludedPicture 1
               create-tweetlink-from myself
               create-tweetlinks-to other [out-following-neighbors] of myself
               ask [out-following-neighbors] of myself [set seen-message? true]
              ]
            set seen-message? true
            set tweet-number tweet-number + 1
          ]
        ]
      ]
    ]
  ]

  [
    if count users with [seen-message?] = 0
    [
      ask n-of 1 users with-max [#followers] with [tweet-message? = false]
      [
        if ext < 30
        [
          ifelse psychopathy = false
          [
           set  tweet-message? true
           hatch-tweets 1
           [
            set fake-news 0
            set number-of-photo 0
            set IncludedPicture 0
            create-tweetlink-from myself
            create-tweetlinks-to other [out-following-neighbors] of myself
            ask [out-following-neighbors] of myself [set seen-message? true]
           ]
          set seen-message? true
          set tweet-number tweet-number + 1
          ]
          [
            set  tweet-fake-message? true
            hatch-tweets 1
            [
             set fake-news 1
             set number-of-photo 0
             set IncludedPicture 0
             create-tweetlink-from myself
             create-tweetlinks-to other [out-following-neighbors] of myself
             ask [out-following-neighbors] of myself [set seen-message? true]
            ]
            set seen-message? true
            set tweet-number tweet-number + 1
          ]
        ]


          if ext >= 30 and ext < 40
        [
          ifelse psychopathy = false
          [
           set  tweet-message? true
           hatch-tweets 1
           [
             set fake-news 0
             set number-of-photo 1
             set IncludedPicture 0.25
             create-tweetlink-from myself
             create-tweetlinks-to other [out-following-neighbors] of myself
             ask [out-following-neighbors] of myself [set seen-message? true]
           ]
          ]
          [
           set  tweet-fake-message? true
           hatch-tweets 1
            [
            set fake-news 1
            set number-of-photo 1
            set IncludedPicture 0.25
            create-tweetlink-from myself
            create-tweetlinks-to other [out-following-neighbors] of myself
            ask [out-following-neighbors] of myself [set seen-message? true]
           ]
           set seen-message? true
           set tweet-number tweet-number + 1
          ]

        if ext >= 40 and ext < 50
        [
          ifelse psychopathy = false
            [
             set  tweet-message? true
             hatch-tweets 1
             [
              set fake-news 0
              set number-of-photo 2
              set IncludedPicture 0.5
              create-tweetlink-from myself
              create-tweetlinks-to other [out-following-neighbors] of myself
              ask [out-following-neighbors] of myself [set seen-message? true]
             ]
              set seen-message? true
              set tweet-number tweet-number + 1
            ]
            [
             set  tweet-fake-message? true
             hatch-tweets 1
              [
               set fake-news 1
               set number-of-photo 2
               set IncludedPicture 0.5
               create-tweetlink-from myself
               create-tweetlinks-to other [out-following-neighbors] of myself
               ask [out-following-neighbors] of myself [set seen-message? true]
              ]
            set seen-message? true
            set tweet-number tweet-number + 1
           ]
        ]
        if ext >= 50 and ext < 60
        [
          ifelse psychopathy = false
           [
            set  tweet-message? true
            hatch-tweets 1
             [
              set fake-news 0
              set number-of-photo 3
              set IncludedPicture 0.75
              create-tweetlink-from myself
              create-tweetlinks-to other [out-following-neighbors] of myself
              ask [out-following-neighbors] of myself [set seen-message? true]
             ]
            set seen-message? true
            set tweet-number tweet-number + 1
            ]
            [
              set  tweet-fake-message? true
              hatch-tweets 1
               [
               set fake-news 1
               set number-of-photo 2
               set IncludedPicture 0.5
               create-tweetlink-from myself
               create-tweetlinks-to other [out-following-neighbors] of myself
               ask [out-following-neighbors] of myself [set seen-message? true]
               ]
             set seen-message? true
             set tweet-number tweet-number + 1
            ]

        if ext >= 60
        [
          ifelse psychopathy = false
              [
               set  tweet-message? true
                hatch-tweets 1
                [
                 set fake-news 0
                 set number-of-photo 4
                 set IncludedPicture 1
                 create-tweetlink-from myself
                 create-tweetlinks-to other [out-following-neighbors] of myself
                 ask [out-following-neighbors] of myself [set seen-message? true]
                ]
                set seen-message? true
                set tweet-number tweet-number + 1
               ]
              [
              set  tweet-fake-message? true
              hatch-tweets 1
              [
               set fake-news 1
               set number-of-photo 4
               set IncludedPicture 1
               create-tweetlink-from myself
               create-tweetlinks-to other [out-following-neighbors] of myself
               ask [out-following-neighbors] of myself [set seen-message? true]
              ]
              set seen-message? true
              set tweet-number tweet-number + 1
              ]
          ]
        ]
     ]
  ]
 ]
]
]

  if #tweet > 1
  [
   ifelse count users with [opn > #openness] > 0
   [
    if count users with [seen-message?] = 0
    [
       ask n-of 1 users with [opn > #openness] with-max [#followers] with [tweet-message? = false]
      [
        if ext < 30
        [
          ifelse psychopathy = false
          [
            set  tweet-message? true
            hatch-tweets 1
            [
              set fake-news 0
              set number-of-photo 0
              set IncludedPicture 0
              create-tweetlink-from myself
              create-tweetlinks-to other [out-following-neighbors] of myself
              ask [out-following-neighbors] of myself [set seen-message? true]
            ]
            set seen-message? true
            set tweet-number tweet-number + 1
          ]
          [
             set  tweet-fake-message? true
             hatch-tweets 1
            [
              set fake-news 1
              set number-of-photo 0
              set IncludedPicture 0
              create-tweetlink-from myself
              create-tweetlinks-to other [out-following-neighbors] of myself
              ask [out-following-neighbors] of myself [set seen-message? true]
            ]
            set seen-message? true
            set tweet-number tweet-number + 1
          ]
        ]
        if ext >= 30 and ext < 40
        [
          ifelse psychopathy = false
            [
              set  tweet-message? true
              hatch-tweets 1
               [
                 set fake-news 1
                 set number-of-photo 1
                 set IncludedPicture 0.25
                 create-tweetlink-from myself
                 create-tweetlinks-to other [out-following-neighbors] of myself
                 ask [out-following-neighbors] of myself [set seen-message? true]
               ]
              set seen-message? true
              set tweet-number tweet-number + 1
            ]
            [
             set  tweet-fake-message? true
              hatch-tweets 1
               [
                set fake-news 1
                set number-of-photo 0
                set IncludedPicture 0
                create-tweetlink-from myself
                create-tweetlinks-to other [out-following-neighbors] of myself
                ask [out-following-neighbors] of myself [set seen-message? true]
               ]
            set seen-message? true
            set tweet-number tweet-number + 1
           ]
        ]
        if ext >= 40 and ext < 50
        [
          ifelse psychopathy = false
             [
              set  tweet-message? true
              hatch-tweets 1
              [
               set fake-news 0
               set number-of-photo 2
               set IncludedPicture 0.5
               create-tweetlink-from myself
               create-tweetlinks-to other [out-following-neighbors] of myself
               ask [out-following-neighbors] of myself [set seen-message? true]
              ]
          set seen-message? true
          set tweet-number tweet-number + 1
             ]
             [
               set  tweet-fake-message? true
               hatch-tweets 1
                [
                 set fake-news 1
                 set number-of-photo 2
                 set IncludedPicture 0.5
                 create-tweetlink-from myself
                 create-tweetlinks-to other [out-following-neighbors] of myself
                 ask [out-following-neighbors] of myself [set seen-message? true]
                ]
             set seen-message? true
             set tweet-number tweet-number + 1
            ]
           ]

        if ext >= 50 and ext < 60
        [
          ifelse psychopathy = false
             [
              set  tweet-message? true
              hatch-tweets 1
              [
               set fake-news 0
               set number-of-photo 3
               set IncludedPicture 0.75
               create-tweetlink-from myself
               create-tweetlinks-to other [out-following-neighbors] of myself
               ask [out-following-neighbors] of myself [set seen-message? true]
              ]
          set seen-message? true
          set tweet-number tweet-number + 1
             ]
             [
               set  tweet-fake-message? true
               hatch-tweets 1
                 [
                  set fake-news 1
                  set number-of-photo 3
                  set IncludedPicture 0.75
                  create-tweetlink-from myself
                  create-tweetlinks-to other [out-following-neighbors] of myself
                  ask [out-following-neighbors] of myself [set seen-message? true]
                 ]
               set seen-message? true
               set tweet-number tweet-number + 1
             ]
        ]
        if ext >= 60
        [
          ifelse psychopathy = false
              [
               set  tweet-message? true
               hatch-tweets 1
                [
                set fake-news 0
                set number-of-photo 4
                set IncludedPicture 1
                create-tweetlink-from myself
                create-tweetlinks-to other [out-following-neighbors] of myself
                ask [out-following-neighbors] of myself [set seen-message? true]
              ]
          set seen-message? true
          set tweet-number tweet-number + 1
             ]
             [
              set  tweet-fake-message? true
              hatch-tweets 1
               [
               set fake-news 1
               set number-of-photo 4
               set IncludedPicture 1
               create-tweetlink-from myself
               create-tweetlinks-to other [out-following-neighbors] of myself
               ask [out-following-neighbors] of myself [set seen-message? true]
              ]
            set seen-message? true
            set tweet-number tweet-number + 1
          ]
        ]
      ]
    ]
  ]

  [
    if count users with [seen-message?] = 0
    [
      ask n-of 1 users with-max [#followers] with [tweet-message? = false]
      [
        if ext < 30
        [
          ifelse psychopathy = false
          [
           set  tweet-message? true
           hatch-tweets 1
           [
            set fake-news 0
            set number-of-photo 0
            set IncludedPicture 0
            create-tweetlink-from myself
            create-tweetlinks-to other [out-following-neighbors] of myself
            ask [out-following-neighbors] of myself [set seen-message? true]
           ]
          set seen-message? true
          set tweet-number tweet-number + 1
          ]
          [
            set  tweet-fake-message? true
            hatch-tweets 1
            [
             set fake-news 1
             set number-of-photo 0
             set IncludedPicture 0
             create-tweetlink-from myself
             create-tweetlinks-to other [out-following-neighbors] of myself
             ask [out-following-neighbors] of myself [set seen-message? true]
            ]
            set seen-message? true
            set tweet-number tweet-number + 1
          ]
        ]


          if ext >= 30 and ext < 40
        [
          ifelse psychopathy = false
          [
           set  tweet-message? true
           hatch-tweets 1
           [
             set fake-news 0
             set number-of-photo 1
             set IncludedPicture 0.25
             create-tweetlink-from myself
             create-tweetlinks-to other [out-following-neighbors] of myself
             ask [out-following-neighbors] of myself [set seen-message? true]
           ]
          ]
          [
           set  tweet-fake-message? true
           hatch-tweets 1
            [
            set fake-news 1
            set number-of-photo 1
            set IncludedPicture 0.25
            create-tweetlink-from myself
            create-tweetlinks-to other [out-following-neighbors] of myself
            ask [out-following-neighbors] of myself [set seen-message? true]
           ]
           set seen-message? true
           set tweet-number tweet-number + 1
          ]

        if ext >= 40 and ext < 50
        [
          ifelse psychopathy = false
            [
             set  tweet-message? true
             hatch-tweets 1
             [
              set fake-news 0
              set number-of-photo 2
              set IncludedPicture 0.5
              create-tweetlink-from myself
              create-tweetlinks-to other [out-following-neighbors] of myself
              ask [out-following-neighbors] of myself [set seen-message? true]
             ]
              set seen-message? true
              set tweet-number tweet-number + 1
            ]
            [
             set  tweet-fake-message? true
             hatch-tweets 1
              [
               set fake-news 1
               set number-of-photo 2
               set IncludedPicture 0.5
               create-tweetlink-from myself
               create-tweetlinks-to other [out-following-neighbors] of myself
               ask [out-following-neighbors] of myself [set seen-message? true]
              ]
            set seen-message? true
            set tweet-number tweet-number + 1
           ]
        ]
        if ext >= 50 and ext < 60
        [
          ifelse psychopathy = false
           [
            set  tweet-message? true
            hatch-tweets 1
             [
              set fake-news 0
              set number-of-photo 3
              set IncludedPicture 0.75
              create-tweetlink-from myself
              create-tweetlinks-to other [out-following-neighbors] of myself
              ask [out-following-neighbors] of myself [set seen-message? true]
             ]
            set seen-message? true
            set tweet-number tweet-number + 1
            ]
            [
              set  tweet-fake-message? true
              hatch-tweets 1
               [
               set fake-news 1
               set number-of-photo 2
               set IncludedPicture 0.5
               create-tweetlink-from myself
               create-tweetlinks-to other [out-following-neighbors] of myself
               ask [out-following-neighbors] of myself [set seen-message? true]
               ]
             set seen-message? true
             set tweet-number tweet-number + 1
            ]

        if ext >= 60
        [
          ifelse psychopathy = false
              [
               set  tweet-message? true
                hatch-tweets 1
                [
                 set fake-news 0
                 set number-of-photo 4
                 set IncludedPicture 1
                 create-tweetlink-from myself
                 create-tweetlinks-to other [out-following-neighbors] of myself
                 ask [out-following-neighbors] of myself [set seen-message? true]
                ]
                set seen-message? true
                set tweet-number tweet-number + 1
               ]
              [
              set  tweet-fake-message? true
              hatch-tweets 1
              [
               set fake-news 1
               set number-of-photo 4
               set IncludedPicture 1
               create-tweetlink-from myself
               create-tweetlinks-to other [out-following-neighbors] of myself
               ask [out-following-neighbors] of myself [set seen-message? true]
              ]
              set seen-message? true
              set tweet-number tweet-number + 1
              ]
          ]
        ]
     ]
  ]
 ]
]
]


  if count users with [seen-message?] = seen-count
  [
    ask users
    [
    set seen-message? false
    set seen-fake-message false
    set tweet-message? false
    set did-comment? false
    set did-like? false
    set seen-fake-message? false
    set tweet-fake-message? false
    set ovtrustdone false
    ]
  ]

end

;;;;;;;;;;;;;;;;;;;;
;;; Trust Model  ;;;
;;;;;;;;;;;;;;;;;;;;

to trust-model
  if any? users with [tweet-message?]
  [
    ask users with [tweet-message?]
    [
     identity-based
     Behavior-based
     Relation-based
     Feedback
     Information-based
     Overall-Trust
     set tweet-message? false
    ]
  ]

   if any? users with [did-comment?]
  [
    ask users with [did-comment?]
    [
     identity-based
     Behavior-based
     Relation-based
     Feedback
     Information-based
     Overall-Trust
     set tweet-message? false
    ]
    ask tweets
    [
       set number-of-comments count in-commentlink-neighbors
    ]
  ]
end

to Identity-based
  ;;;;;POPULARITY FACTOR;;;;;;
   Set followersi count [out-following-neighbors] of self
   Set followersj max [followersi] of users
   Set Popularity_Factor ((log (followersI + 1) 2)/(log (followersJ + 1) 2))

  ;;;;AGE FACTOR;;;;
   set Age_factor age / (age + mean [age] of users)

  ;;;;AUTHORITY FACTOR;;;;
   ifelse authority = 1
    [ set authority_factor 1 ] [ set authority_factor 0 ]

  ;;;;;identitybased;;;;;
      set IdentityFactor (Popularity_Factor + Age_factor + authority_factor) / 3
end

to Behavior-based
  ;;;;;;influence;;;;;;;
  if any? tweets
  [
   ask tweets
    [
      set likes-tweet ( log ( number-of-likes + 1) 10 ) / ( log ( max [number-of-likes] of tweets + 1) 10 + 1)
      set share-tweet ( log ( number-of-shares + 1) 10 ) / ( log ( max [ number-of-shares] of tweets + 1) 10 + 1 )
      set comment-tweet ( log ( number-of-comments + 1) 10 ) / ( log ( max [ number-of-comments] of tweets + 1) 10 + 1 )
      set Influence (likes-tweet + comment-tweet + share-tweet) / 3
           ;set influenceT influence / sum [influence] of tweets
          ]
    ]
    if count out-tweetlink-neighbors > 0[
    set BehaviorFactor 1 - ( ( sum [influence] of out-tweetlink-neighbors ) / ( sum [influence] of tweets + 1))
    ]

  ;;;;;users likes behavior;;;;;;;
  if any? users with [true-likes > 0 or fake-likes > 0]
  [
    ask users with [true-likes > 0 or fake-likes > 0]
    [
      set users-likes-behavior ( ( ( log ( true-likes + 1) 10 ) / ( log ( max [true-likes] of users + 1) 10 + 1) ) / ( ( log ( true-likes + 1) 10 ) / ( log ( max [true-likes] of users + 1) 10 + 1) +
        ( log ( fake-likes + 1) 10 ) / ( log ( max [fake-likes] of users + 1) 10 + 1) ) )
    ]
  ]
  ;;;;;users shares behavior;;;;
   if any? users with [true-shares > 0 or fake-shares > 0 or true-discards > 0 or fake-discards > 0]
  [
    ask users with [true-shares > 0 or fake-shares > 0 or true-discards > 0 or fake-discards > 0]
    [
      set users-shares-behavior ( ( ( ( log ( true-shares + 1) 10 ) / ( log ( max [true-shares] of users + 1) 10 + 1) ) + ( ( log ( fake-discards + 1) 10 ) / ( log ( max [fake-discards] of users + 1) 10 + 1) ) ) /
        ( ( ( ( log ( true-shares + 1) 10 ) / ( log ( max [true-shares] of users + 1) 10 + 1) ) + ( ( log ( fake-discards + 1) 10 ) / ( log ( max [fake-discards] of users + 1) 10 + 1) ) ) +
          ( log ( true-discards + 1) 10 ) / ( log ( max [true-discards] of users + 1) 10 + 1) + ( log ( fake-shares + 1) 10 ) / ( log ( max [fake-shares] of users + 1) 10 + 1) ) )
    ]
  ]
  ;;;;influence of receiving users;;;;
  ask users with [count out-tweetlink-neighbors = 0]
  [
    set BehaviorFactor ( users-likes-behavior + users-shares-behavior ) / 2
  ]
end

to-report global-clustering-coefficient
  nw:set-context users followings
  let closed-triplets sum [ nw:clustering-coefficient  * count my-followings * (count my-followings - 1) ] of users
  let triplets sum [ count my-followings * (count my-followings - 1) ] of users
  report closed-triplets / triplets
end

to Relation-based
  nw:set-context users followings
  ask users ;with [message?]
  [
    Set LocalClustering nw:clustering-coefficient
    let a nw:betweenness-centrality
    let b count following-neighbors
   let div ((a)) / b * a
    if div = 0 [set div 1]
   Set BetweenessCentrality (nw:betweenness-centrality) / (div)
   Set RelationFactor (LocalClustering + (1 - BetweenessCentrality)) /  2
  ]
end

to Feedback
  ask tweets
  [
    if any? in-commentlink-neighbors with [positive-comment]
    [
      set positive-comment-tweet count in-commentlink-neighbors with [positive-comment]
    ]
    if any? in-commentlink-neighbors with [negative-comment]
    [
      set negative-comment-tweet count in-commentlink-neighbors with [negative-comment]
    ]
  ]
  ask users
  [
    if any? in-commentlink-neighbors
    [
      ifelse any? out-tweetlink-neighbors
      [
        let true-positive sum [positive-comment-tweet] of out-tweetlink-neighbors with [fake-news = 0]
        let fake-positive sum [positive-comment-tweet] of out-tweetlink-neighbors with [fake-news = 1]
        let true-negative sum [negative-comment-tweet] of out-tweetlink-neighbors with [fake-news = 0]
        let fake-negative sum [negative-comment-tweet] of out-tweetlink-neighbors with [fake-news = 1]
        set FeedbackFactor ((true-positive + fake-negative) / ((true-positive + fake-negative)+(true-positive + fake-negative) + 4))
      ]
      [
      set FeedbackFactor (count in-commentlink-neighbors with [positive-comment])/ (count in-commentlink-neighbors with [positive-comment] + count in-commentlink-neighbors with [negative-comment])
      ]
    ]
  ]
end

to Information-based
 if any? tweets
  [
    ask tweets
    [
      set tweet-accuracy count in-commentlink-neighbors with [positive-comment] + 1 / (count in-commentlink-neighbors with [positive-comment] + count in-commentlink-neighbors with [negative-comment] + 2)
      set tweet-logic [ ( con_value / (con_value + neu_value )) * 0.5 + know * 0.5] of one-of in-tweetlink-neighbors
      set tweet-popularity count out-tweetlink-neighbors / count users with [seen-message?]
    ]
  ]
  if any? comments
  [
     ask comments
     [
       set comment-accuracy [con_value * 0.005 + know * 0.5] of one-of in-commentlink-neighbors
       set comment-logic [ con_value * 0.005 + know * 0.5] of one-of in-commentlink-neighbors
     ]
  ]

  ask users
  [
      ifelse any? out-tweetlink-neighbors
      [
        let content-accuracy mean [tweet-accuracy] of out-tweetlink-neighbors
        let included-photos mean [IncludedPicture] of out-tweetlink-neighbors
        let logic mean [tweet-logic] of out-tweetlink-neighbors
        let PostPopularity mean [tweet-popularity] of out-tweetlink-neighbors

        Set informationFactor content-accuracy * 0.4  + included-photos * 0.2 + logic * 0.3 + PostPopularity * 0.1
      ]
      [
        if any? out-commentlink-neighbors
        [
          let content-accuracy mean [comment-accuracy] of out-commentlink-neighbors
          let logic mean [comment-logic] of out-commentlink-neighbors

          Set informationFactor content-accuracy * 0.57  + logic * 0.43
        ]
      ]
  ]
end

to overall-trust
  ;ask users [set %trust ifelse-value (%trust < 1) [(IdentityFactor * #widentity-based) + (BehaviorFactor * #wbehavior-based) + (RelationFactor * #wrelation-based) + (FeedbackFactor * #wfeedbackFactor) +
    ;(InformationFactor * #winformation-based)] [1]set ovtrustdone true]

  ask users [
    set %trust (IdentityFactor * #widentity-based) + (BehaviorFactor * #wbehavior-based) + (RelationFactor * #wrelation-based) + (FeedbackFactor * #wfeedbackFactor) + (InformationFactor * #winformation-based)
    set ovtrustdone true
  ]
end

;;;;;;;;;;;;;;;;;;
;;; Responses  ;;;
;;;;;;;;;;;;;;;;;;
to response

  ;;;;share;;;;

  ask users with [seen-message? = true and count out-tweetlink-neighbors = 0]
    [
      ifelse random 5 * 1.7 > 5 - log ( con_value * (0.576)) 2
      [
        create-sharelinks-to other [out-following-neighbors] of self
        set true-shares true-shares + 1
        ask [out-sharelink-neighbors] of self
        [
          create-tweetlink-from one-of [in-tweetlink-neighbors] of one-of in-sharelink-neighbors
          ;trust-model
          set seen-message? true
          ask [in-tweetlink-neighbors] of self
          [
            set number-of-shares number-of-shares + 1
          ]
        ]
      ]
      [
        set true-discards true-discards + 1
      ]
    ]

  ask users with [seen-fake-message? = true]
    [
      ifelse random 5 * 1.7 > 5 - log ( con_value * (0.576)) 2
      [
        create-sharelinks-to other [out-following-neighbors] of self
        set fake-shares fake-shares + 1
        ask [out-sharelink-neighbors] of self
        [
          create-tweetlink-from one-of [in-tweetlink-neighbors] of one-of in-sharelink-neighbors
          ;trust-model
          set seen-fake-message? true
          ask [in-tweetlink-neighbors] of self
          [
            set number-of-shares number-of-shares + 1
          ]
        ]
      ]
      [
        set fake-discards fake-discards + 1
      ]
    ]


;;;;comments;;;;
  ask users with [seen-message? and did-comment? = false]
  [
    let probability-seen-agr agr_value
    let random-agr random 100
    ifelse random-agr <= probability-seen-agr
    [
     hatch-comments 1 [
        create-commentlink-from myself set negative-comment false set positive-comment true
        create-commentlinks-to other [in-tweetlink-neighbors] of myself
        create-commentlinks-to other [out-following-neighbors] of myself
        if [in-commentlink-neighbors] of in-tweetlink-neighbors with [positive-comment] = true
        [
          create-commentlinks-to other [in-commentlink-neighbors] of in-tweetlink-neighbors with [positive-comment]
        ]
      ]
      set did-comment? true
    ]

   [
    hatch-comments 1
      [
        create-commentlink-from myself set negative-comment true set positive-comment false
        create-commentlinks-to other [in-tweetlink-neighbors] of myself
        create-commentlinks-to other [out-following-neighbors] of myself
        if [in-commentlink-neighbors] of in-tweetlink-neighbors with [positive-comment] = true
        [
          create-commentlinks-to other [in-commentlink-neighbors] of in-tweetlink-neighbors with [positive-comment]
        ]
      ]
  ]
    set did-comment? true
  ]

  ask users with [%trust < 0.5 and did-comment? = false]
  [
    if out-commentlink-neighbors = 0
    [
   hatch-comments 1
      [
        create-commentlink-from myself set negative-comment false set positive-comment true
        create-commentlinks-to other [in-tweetlink-neighbors] of myself
        create-commentlinks-to other [out-following-neighbors] of myself
        if [in-commentlink-neighbors] of in-tweetlink-neighbors with [positive-comment] = true
        [
          create-commentlinks-to other [in-commentlink-neighbors] of in-tweetlink-neighbors with [positive-comment]
        ]
      ]
   set did-comment? true
    ]
  ]

  layout

  ;;;likes;;;;

  ask users with [seen-message?]
  [
    if did-like? = false
    [
      let prob-open opn_value / 100 * openness-like
      let abr-opn random 100
      if abr-opn <= prob-open
      [
        ask in-tweetlink-neighbors
        [
          set number-of-likes number-of-likes + 1
        ]
        set did-like? true
        if any? in-tweetlink-neighbors with [fake-news = 1]
        [
          set fake-likes fake-likes + 1
        ]
        if any? in-tweetlink-neighbors with [fake-news = 0]
        [
          set true-likes true-likes + 1
        ]
      ]
    ]
    if did-like? = false
    [
      let prob-con con_value / 100 * conscientiousness-like
      let abr-con random 100
      if abr-con <= prob-con
      [
        ask in-tweetlink-neighbors
        [
          set number-of-likes number-of-likes + 1
        ]
       set did-like? true
        if any? in-tweetlink-neighbors with [fake-news = 1]
        [
          set fake-likes fake-likes + 1
        ]
        if any? in-tweetlink-neighbors with [fake-news = 0]
        [
          set true-likes true-likes + 1
        ]
      ]
    ]
    if did-like? = false
    [
      let prob-agr agr_value / 100 * agreeableness-like
      let abr-agr random 100
      if abr-agr <= prob-agr
      [
        ask in-tweetlink-neighbors
        [
          set number-of-likes number-of-likes + 1
        ]
        set did-like? true
        if any? in-tweetlink-neighbors with [fake-news = 1]
        [
          set fake-likes fake-likes + 1
        ]
        if any? in-tweetlink-neighbors with [fake-news = 0]
        [
          set true-likes true-likes + 1
        ]
      ]
    ]
    if did-like? = false
    [
      let prob-ext ext_value / 100 * extroversion-like
      let abr-ext random 100
      if abr-ext <= prob-ext
      [
        ask in-tweetlink-neighbors
        [
          set number-of-likes number-of-likes + 1
        ]
        set did-like? true
        if any? in-tweetlink-neighbors with [fake-news = 1]
        [
          set fake-likes fake-likes + 1
        ]
        if any? in-tweetlink-neighbors with [fake-news = 0]
        [
          set true-likes true-likes + 1
        ]
      ]
    ]
  if did-like? = false
    [
      let prob-neu neu_value / 100 * neuroticism-like
      let abr-neu random 100
      if abr-neu <= prob-neu
      [
        ask in-tweetlink-neighbors
        [
          set number-of-likes number-of-likes + 1
        ]
        set did-like? true
        if any? in-tweetlink-neighbors with [fake-news = 1]
        [
          set fake-likes fake-likes + 1
        ]
        if any? in-tweetlink-neighbors with [fake-news = 0]
        [
          set true-likes true-likes + 1
        ]
      ]
    ]
]
end



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Fake News Dissemination ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to fake-news-dissemination
  if mean [%trust] of users > 0.5
  [
    If Random-float 100 <= fake-news-sharing-probability * 100
    [
      ask users
      [
       let share-fake? #psychopathy * fake-news-sharing-probability
       let prob-fake random 100
       if prob-fake <= share-fake?
        [
          if tweet-fake-message? = false
            [
              if ext_value < 30
                [
                  hatch-tweets 1
                   [
                     create-tweetlink-from myself
                     set number-of-photo 2
                     set fake-news 1
                     ask out-tweetlink-neighbors [set color black]
                     set color black
                     create-tweetlinks-to other [out-following-neighbors] of myself
                     ask [out-following-neighbors] of myself
                       [
                        trust-model
                        set seen-fake-message? true
                        set seen-message? true
                       ]
                   ]
                  set tweet-fake-message?  true
                ]
               if ext_value >= 30 and ext_value < 40
                [
                 hatch-tweets 1
                    [
                    create-tweetlink-from myself
                    set number-of-photo 0
                    set fake-news 1
                    ask out-tweetlink-neighbors [set color black]
                    set color black
                    create-tweetlinks-to other [out-following-neighbors] of myself
                    ask [out-following-neighbors] of myself
                     [
                      trust-model
                      set seen-fake-message? true
                     ]
                  ]
                  set tweet-fake-message? true
                ]
               if ext_value >= 40 and ext_value < 50
                [
                 hatch-tweets 1
                  [
                    create-tweetlink-from myself
                    set number-of-photo 0
                    set fake-news 1
                    ask out-tweetlink-neighbors [set color black]
                    set color black
                    create-tweetlinks-to other [out-following-neighbors] of myself
                    ask [out-following-neighbors] of myself
                     [
                      trust-model
                      set seen-fake-message? true
                     ]
                  ]
                set tweet-fake-message? true
                 ]
                if ext_value >= 50 and ext_value < 60
                 [
                  hatch-tweets 1
                   [
                     create-tweetlink-from myself
                     set number-of-photo 0
                     set fake-news 1
                     ask out-tweetlink-neighbors [set color black]
                     set color black
                     create-tweetlinks-to other [out-following-neighbors] of myself
                     ask [out-following-neighbors] of myself
                      [
                       trust-model
                      set seen-fake-message? true
                      ]
                   ]
                set tweet-fake-message? true
                 ]
                if ext_value >= 60
                 [
                   hatch-tweets 1
                    [
                     create-tweetlink-from myself
                     set number-of-photo 0
                     set fake-news 1
                     ask out-tweetlink-neighbors [set color black]
                     set color black
                     create-tweetlinks-to other [out-following-neighbors] of myself
                     ask [out-following-neighbors] of myself
                     [
                       trust-model
                      set seen-fake-message? true
                     ]
                    ]
                  set tweet-fake-message? true
                  ]
           ]
        ]
     ]
  ]
  ]
  if any? tweets with [fake-news = 1]
  [
    if mean [%trust] of users > 0.5 and count tweets / count users > 0.5
    [
      ask users with [opn = #openness]
      [
        create-tweetlink-from one-of tweets with [fake-news = 1]
        set seen-fake-message? true
        trust-model
        set seen-message? true
      ]
    ]
  ]
  if count comments with [negative-comment] > count users / 2
  [
    ask tweets with [fake-news = 1]
    [
      ;ask in-commentlink-neighbors [die]
      ;die
    ]
    ;ask users with [faketweets = 1] [set faketweets 0]
  ]
  ;if any? tweets with [fake-news = 1] [if mean [%trust] of users < 0.7 [ask tweets with [fake-news = 1] [die]]]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Following Changes  ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

to following-procedure
  ask users with [count in-following-neighbors > 0] [
    if any? out-commentlink-neighbors with [negative-comment] and con_value > 50 [
      ask in-commentlink-neighbors with [negative-comment] [
        die
      ]
    ]
  ]
end

to remove-incoming-links [links-to-remove]
  ask links-to-remove [
    if end1 != nobody [ ask end2 [ die ] ]
  ]
end
;;;;;;;;;;;;;;;;;;;;;;;;;
;;; System Interface  ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;

to set-questionnaire
  set #widentity-based 0.18
  set #wbehavior-based 0.08
  set #wrelation-based 0.04
  set #wfeedbackfactor 0.08
  set #winformation-based 0.62
end

to set-equal
  set #widentity-based 0.2
  set #wbehavior-based 0.2
  set #wrelation-based 0.2
  set #wfeedbackfactor 0.2
  set #winformation-based 0.2
end


to showlink
  ask tweetlinks [set color blue]
  layout
end

to hide-following
  ask followings [ifelse color = red [set color [0 0 0 0]] [set color red]]
end

to hide-commentlink
  ask commentlinks [ifelse color = lime [set color [0 0 0 0]] [set color lime]]
end
to hide-tweetlink
  ask tweetlinks [ifelse color = blue [set color [0 0 0 0]][ifelse color = black []  [set color blue]]]
end

to hide-tweet
  ask tweets [ifelse color = blue [set color [0 0 0 0]][ifelse color = black [] [set color blue]]]
  ask tweetlinks [ifelse color = blue [set color [0 0 0 0]] [set color blue]]
end
to hide-comment
  ask comments [ifelse color = lime [set color [0 0 0 0]] [set color lime]]
   ask commentlinks [ifelse color = lime [set color [0 0 0 0]] [set color lime]]
end
@#$#@#$#@
GRAPHICS-WINDOW
9
10
584
586
-1
-1
13.83
1
10
1
1
1
0
0
0
1
-20
20
-20
20
0
0
1
ticks
40.0

SLIDER
912
563
1084
596
#user
#user
0
1000
100.0
1
1
NIL
HORIZONTAL

SLIDER
911
287
1083
320
opn
opn
0
100
48.01
1
1
NIL
HORIZONTAL

SLIDER
1087
287
1259
320
opn_std
opn_std
0
100
8.95
1
1
NIL
HORIZONTAL

TEXTBOX
913
267
1063
285
Big-Five Personality Setup
12
0.0
1

SLIDER
912
324
1084
357
con
con
0
100
47.19
1
1
NIL
HORIZONTAL

SLIDER
1087
324
1259
357
con_std
con_std
0
100
11.24
0.01
1
NIL
HORIZONTAL

SLIDER
912
360
1084
393
ext
ext
0
100
51.25
1
1
NIL
HORIZONTAL

SLIDER
1088
360
1260
393
ext_std
ext_std
0
100
8.81
1
1
NIL
HORIZONTAL

SLIDER
912
397
1084
430
agr
agr
0
100
46.38
1
1
NIL
HORIZONTAL

SLIDER
1089
397
1261
430
agr_std
agr_std
0
100
9.02
1
1
NIL
HORIZONTAL

SLIDER
912
434
1084
467
neu
neu
0
100
49.73
1
1
NIL
HORIZONTAL

SLIDER
1089
434
1261
467
neu_std
neu_std
0
100
9.66
1
1
NIL
HORIZONTAL

TEXTBOX
913
541
1063
559
Users Setup\n
12
0.0
1

SLIDER
912
599
1084
632
#age-val
#age-val
0
10
3.5
0.5
1
NIL
HORIZONTAL

SLIDER
913
636
1085
669
#auth-val
#auth-val
0
1
1.0
1
1
NIL
HORIZONTAL

SLIDER
1111
562
1283
595
know
know
0
1
0.5
0.1
1
NIL
HORIZONTAL

SLIDER
1284
562
1456
595
know_std
know_std
0
1
0.5
0.1
1
NIL
HORIZONTAL

SLIDER
1110
598
1282
631
psy
psy
0
1
0.5
0.1
1
NIL
HORIZONTAL

SLIDER
1283
598
1455
631
psy_std
psy_std
0
1
0.5
0.1
1
NIL
HORIZONTAL

TEXTBOX
913
20
1063
38
Trust Model
12
0.0
1

SLIDER
1276
284
1448
317
#openness
#openness
0
1
0.2
0.1
1
NIL
HORIZONTAL

SLIDER
1276
320
1448
353
#conscientiousness
#conscientiousness
0
1
0.2
0.1
1
NIL
HORIZONTAL

SLIDER
913
75
1085
108
#widentity-based
#widentity-based
0
1
0.18
0.01
1
NIL
HORIZONTAL

SLIDER
913
111
1085
144
#wbehavior-based
#wbehavior-based
0
1
0.08
0.01
1
NIL
HORIZONTAL

SLIDER
914
147
1086
180
#wrelation-based
#wrelation-based
0
1
0.04
0.01
1
NIL
HORIZONTAL

SLIDER
914
182
1086
215
#wfeedbackfactor
#wfeedbackfactor
0
1
0.08
0.01
1
NIL
HORIZONTAL

SLIDER
914
219
1087
252
#winformation-based
#winformation-based
0
1
0.62
0.01
1
NIL
HORIZONTAL

TEXTBOX
1278
265
1428
283
Big-5 spectrum
12
0.0
1

SLIDER
913
40
1085
73
#setuptrust
#setuptrust
0
1
0.5
0.1
1
NIL
HORIZONTAL

SLIDER
1276
356
1448
389
#extraversion
#extraversion
0
1
0.2
0.1
1
NIL
HORIZONTAL

SLIDER
1276
397
1448
430
#agreeableness
#agreeableness
0
1
0.2
0.1
1
NIL
HORIZONTAL

SLIDER
1276
434
1448
467
#neuroticism
#neuroticism
0
1
0.2
0.1
1
NIL
HORIZONTAL

SLIDER
1103
40
1274
73
fake-news-sharing-probability
fake-news-sharing-probability
0
1
0.5
0.1
1
NIL
HORIZONTAL

BUTTON
13
600
161
633
NIL
Setup-scale-free-network
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
12
637
83
670
NIL
clear
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
87
638
160
671
NIL
showlink
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
166
638
289
671
NIL
start
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
167
676
289
709
NIL
start
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
169
601
288
634
NIL
variable-setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
13
674
160
707
NIL
hide-following
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
914
482
1043
515
NIL
Big-5-standards
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
1104
75
1276
108
#psychopathythresh
#psychopathythresh
0
100
50.0
1
1
NIL
HORIZONTAL

SLIDER
1105
111
1277
144
thresholdfollowers
thresholdfollowers
0
10
5.0
1
1
NIL
HORIZONTAL

PLOT
599
16
883
228
Mean Trust
NIL
NIL
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mean [%trust] of users with [seen-message?]"

MONITOR
789
17
881
62
NIL
mean [%trust] of users with [seen-message?]
17
1
11

MONITOR
613
245
772
290
NIL
mean [identityfactor] of users with [seen-message?]
17
1
11

MONITOR
613
292
774
337
NIL
mean [behaviorfactor] of users with [seen-message?]
17
1
11

MONITOR
613
338
774
383
NIL
mean [relationfactor] of users with [seen-message?]
17
1
11

MONITOR
612
385
774
430
NIL
mean [informationfactor] of users with [seen-message?]
17
1
11

MONITOR
613
432
774
477
NIL
mean [feedbackfactor] of users with [seen-message?]
17
1
11

MONITOR
614
577
776
622
NIL
mean [age_factor] of users
17
1
11

MONITOR
614
625
778
670
NIL
mean [age] of users
17
1
11

MONITOR
614
482
777
527
NIL
mean [number-of-shares] of tweets
17
1
11

SLIDER
1471
289
1643
322
openness-like
openness-like
0
100
49.5
1
1
NIL
HORIZONTAL

TEXTBOX
1472
267
1622
285
liking probability
12
0.0
1

SLIDER
1472
326
1645
359
conscientiousness-like
conscientiousness-like
0
100
51.3
1
1
NIL
HORIZONTAL

SLIDER
1472
360
1644
393
extroversion-like
extroversion-like
0
100
61.8
1
1
NIL
HORIZONTAL

SLIDER
1474
429
1646
462
neuroticism-like
neuroticism-like
0
100
79.5
1
1
NIL
HORIZONTAL

SLIDER
1474
395
1646
428
agreeableness-like
agreeableness-like
0
100
24.0
1
1
NIL
HORIZONTAL

MONITOR
614
529
777
574
NIL
mean [number-of-likes] of tweets
17
1
11

MONITOR
781
246
851
291
NIL
count users with [seen-message?]
17
1
11

MONITOR
615
673
779
718
NIL
mean [users-shares-behavior] of users
17
1
11

MONITOR
613
720
781
765
NIL
mean [users-likes-behavior] of users
17
1
11

MONITOR
781
483
857
528
NIL
mean [number-of-discards] of tweets
17
1
11

MONITOR
781
530
857
575
NIL
mean [fake-discards] of users
17
1
11

MONITOR
527
10
584
55
NIL
ticks
17
1
11

SLIDER
913
674
1085
707
#tweet
#tweet
1
10
1.0
1
1
NIL
HORIZONTAL

MONITOR
781
338
851
383
NIL
seen-count
17
1
11

MONITOR
781
292
851
337
NIL
tweet-number
17
1
11

MONITOR
391
616
576
661
NIL
count users with [psychopathy = 1]
17
1
11

MONITOR
391
663
575
708
NIL
mean [#psychopathy] of users
17
1
11

MONITOR
782
388
853
433
NIL
count comments with [positive-comment]
17
1
11

MONITOR
782
436
854
481
NIL
count comments with [negative-comment]
17
1
11

SLIDER
1111
635
1283
668
first-fake-news
first-fake-news
0
1
0.0
1
1
NIL
HORIZONTAL

BUTTON
1096
218
1208
251
NIL
set-questionnaire
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
1209
218
1297
251
NIL
set-equal
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
390
708
576
753
NIL
mean [comment-logic] of comments
17
1
11

@#$#@#$#@
## WHAT IS IT?

Trust model is a trustworthiness evaluation for SNS users while sending and receiving tweets. The model form by barabasi-albert model of scale-free network. This model works on fake news and true news spreading, which is resulting behavior from the big-five personality traits.

## HOW IT WORKS

First, the program generate SNS users according to the setup values. Then the program will pick one openness users to spread the first news and then the other users can create comments and able to shares to the receiving news.

## HOW TO USE IT

First, press the "Setup-scale-free-network" button to generate the users. Then press "start" button to start the dissemination process.


## NETLOGO FEATURES

Blue box represents the tweets.
Person represents users.
Triangle represents comments. 

## RELATED MODELS

The users generation is based on: Albert-László Barabási. Linked: The New Science of Networks, Perseus Publishing, Cambridge, Massachusetts, pages 79-92.


## CREDITS AND REFERENCES

This is the part of simulation program which is submitted for the Journal of Social Network Analysis and Mining.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="baseline" repetitions="100" runMetricsEveryStep="true">
    <setup>setup-scale-free-network</setup>
    <go>1tart</go>
    <timeLimit steps="10"/>
    <metric>count tweets</metric>
    <metric>mean [ %trust ] of users with [seen-message?]</metric>
    <enumeratedValueSet variable="know_std">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="know">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fake-news-sharing-probability">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ext_std">
      <value value="8.81"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="#conscientiousness">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="openness-like">
      <value value="49.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="#neuroticism">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="#winformation-based">
      <value value="0.62"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="agreeableness-like">
      <value value="24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="#auth-val">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="conscientiousness-like">
      <value value="51.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="psy">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="#wbehavior-based">
      <value value="0.08"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="opn_std">
      <value value="8.95"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neuroticism-like">
      <value value="79.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_std">
      <value value="11.24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="#user">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="opn">
      <value value="48.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="#extraversion">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="#setuptrust">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ext">
      <value value="51.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con">
      <value value="47.19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="first-fake-news">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="#widentity-based">
      <value value="0.18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="#tweet">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="extroversion-like">
      <value value="61.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="#psychopathythresh">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neu">
      <value value="49.73"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="#wrelation-based">
      <value value="0.04"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="#openness">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="psy_std">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="agr">
      <value value="46.38"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="thresholdfollowers">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="agr_std">
      <value value="9.02"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="#age-val">
      <value value="3.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="#wfeedbackfactor">
      <value value="0.08"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="#agreeableness">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neu_std">
      <value value="9.66"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
