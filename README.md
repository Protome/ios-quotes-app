# ios-quotes-app

iOS App which uses the Goodreads API to load random quotes and display them for the user.

TO RUN: You will need an API key and Secret from Goodreads! Add a Secrets.strings file (there should be a broken reference to it in the project) with the following in it:

"goodreads_key" = [YOUR KEY];
"goodreads_secret" = [YOUR SECRET];

Currently allows users to
- Load and view random quotes
- Add filters to the quotes to restrict them to specific tags/books/authors
- Share an image of these quotes to social media (and wherever else)
- Login to Goodreads and add the books the quote they are viewing is from to one of their shelves
- Search for books
- Search specifically for quotes from books in the user's goodreads shelves

Roadmap
- Adding RXSwift
- ~~Add proper Dependency Injection (probably with Swinject)~~ Now added!
- Some bugfixing
- The ability to add a new shelf to your Goodreads
- Make those ugly settings screens look nicer
