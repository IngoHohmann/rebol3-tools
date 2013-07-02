rebol3-tools
============

Some tools and experiments for Rebol3

*   load-all.r3
   
    An experiment to use load/next/error to load normally not loadable data.
   
        load-all "As you see, this is a test. We'll be going 500km together"
      
        == [As you see #"," this is a test. We'll be going 500 km together]
   
    You can use your own error handlers:

        load-all/on-error "text: , This will be a string, so everything goes. 500km, if need be.^/no string here" :line-string-handler

        == [text: {This will be a string, so everything goes. 500km, if need be.}
	    no string here
        ]
