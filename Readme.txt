TODO: Nothing! :)

Known issue:
	• About plural. In French, the singular form is used for 0.
	  For other languages, the plural form is used in that case.
	  I did not treated French differently, all languages use
	  plural form when there is 0 elements.

To generate the file iTunes.h:
	sdef /Applications/iTunes.app | sdp -fh --basename "iTunes"
