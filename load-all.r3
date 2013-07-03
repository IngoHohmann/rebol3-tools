REBOL [
   Title: "Load/ALL"
   Author: "Ingo Hohmann"
   Version: 0.0.2
   Date: 2013-07-02
   About: {
      A proof of concept for using LOAD to load data, which would normally not be loadable by Rebol3
   }
   Known-Errors: [
      {rebol returns wrong error when loading strings like "1abcde"}
   ]
]

tne: funct [ 
   "call transcode/next/error to binary! s"
   s [binary! string!]
][
   r: transcode/next/error to binary! s
   change at r 2 to string! r/2
   r
]

number: charset [#"0" - #"9" #"'"]

string-handler: funct [
   "Handler changing everything unloadable to strings"
   pos
   err
   next-pos
][
   val: to binary! err/arg2
   change/part find pos val to binary! mold err/arg2 length? err/arg2 
]

line-string-handler: funct [
   "Handler changing everything from ',' to end of line into string"
   pos
   err
   next-pos
][
   val: to binary! err/arg2
   either all ['invalid = err/id "word" = err/arg1 "," = err/arg2 ][
      parse next-pos [ [to newline | to end ] line-end: (insert line-end {"})]
      change/part find pos val to binary! {"} 2 
   ][
      change/part find pos val to binary! mold err/arg2 length? err/arg2 
   ]
]

default-handler: funct [
   "Resolver changing 10km to 10 km, searching for ',' in words, changing everything else to string"
   pos
   err
   next-pos
][ 
   val: to binary! err/arg2
   new-val: copy err/arg2
   case [
      all ['invalid = err/id "integer" = err/arg1]
	    [
	       parse new-val: copy err/arg2 [opt ["+" | "-"] some [number] here: (insert here #" ")]
	       change/part find pos val to binary! new-val length? err/arg2 
	    ]
      all ['invalid = err/id "word" = err/arg1]
	    [
	       if err-pos: find new-val #"," [
		  insert next err-pos {"}
		  insert err-pos { #"}
	       ]
	       change/part find pos val to binary! new-val length? val 
	    ]
      true
	    [
	       change/part find pos val to binary! mold err/arg2 length? err/arg2 
	    ]
      ]
]

load-all: funct [ 
   "Load data, which would normally stop loading with an error"
   data [binary! string!] 
   /on-error handler [function!]
][
   if not on-error [handler: :default-handler]
   pos: to binary! data ; we need binary! for transcode 
   block: copy []
   until [
      set/any [val: new-pos:] transcode/next/error pos
      either error? val [
	 handler pos val new-pos
      ][
	 append/only block val
	 pos: new-pos
      ]
      empty? pos
   ]
   block
]
