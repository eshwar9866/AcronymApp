# Acronyms

This is a simple iPhone app created to look up meanings of Acronyms / Initialisms.

App supports iOS 7.0 and later.

App is developed using Storyboards and has two screens.

1. Acronyms & Meanings screen: 
    This has a textfield which accepts valid Acronyms / Initialisms. 
    On entering the text and hit "search" key, webservice is made and corresponding meanings are shown in a table view.
   If no meanings are found / if any webservice errors, an alert is shown with appropriate message.
  Validations on textfield: a. accepts only alpha numeric values.
                          b. maximum length of 30
                          c. atleast 1 character.

2. Variations screen: This screen lists all possible variations for a meaning. 
    Again a table view is used to show the content.


Below API is used to fetch the meanings:

http://www.nactem.ac.uk/software/acromine/rest.html

It's a GET request

Cocoapods are used as dependency manager to add below projects:

1.  "AFNetworking", "~> 2.0" (https://github.com/AFNetworking/AFNetworking)

2. 'MBProgressHUD', '~> 0.9.1' (https://github.com/jdg/MBProgressHUD)






