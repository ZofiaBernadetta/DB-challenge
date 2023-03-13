# DB-challenge

Ones you have logged into the app, you can view a timeline of all the posts created by your user. At the moment valid user ids are numbers from 1 to 10. You can favorite posts by tapping the heart icon on each post. Both the login state and the favorites are persisted and cleared out when you logout.

The IDs of your favorite posts are persisted using CoreData. The login state is persisted in the keychain. While currently we aren't storing any true secrets for login (as we only store the user ID), the KeychainHelper demonstrates where we would eventually store any such secrets.

The PostsManager is model layer object responsible for loading the posts and assigning the favorite state. It handles all the relevant networking and database operations and is tested thoroughly.
