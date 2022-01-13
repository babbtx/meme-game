# meme-game

This is a toy API useful for demonstrating fine-grained, external authorization use cases for APIs.
It is written in Ruby on Rails and backed by a PostgreSQL database.

## Background

Organizations are seeking ways to decouple business rules
and fine-grained authorization logic from core application logic and features
and move authorization to a more centralized model for management.

Their drivers:
* Faster time to market for initiatives around API platforms, data privacy, risk and fraud, and user experience
* Data-privacy regulations like GDPR and CCPA give citizens more control over their data
* Decreasing transactional fraud and account takeovers with continuous risk assessment
* Less mistakes and breaches through consistency in approach and execution 
* Decreased time to audit and test through centralized management 

[PingAuthorize](https://www.pingidentity.com/en/software/pingauthorize.html)
is a software solution that integrates into your application and API services
to externalize fine-grained authorization and data security.
Through centralized policy enforcement, dynamic authorization,
and attribute-based access control (ABAC), 
organizations can externalize business logic
from application and API code and achieve their goals.

This toy API provides some common patterns of RESTful APIs. You can
use this to play with PingAuthorize's features for dynamic authorization,
fine-grained access control, data masking, and data filtering.

# The Game

## Scenario

Imagine an online game of competitively creating captions for funny memes.
Each player is given an image and asked to give it a caption.
At the end of each round, the players would enjoy each other's creativity,
and maybe vote for their favorites. At the end of a game or several games,
perhaps you'd want to share your best memes with your family or other friends.

Why not demonstrate enterprise software with a light-hearted API? It's humor, people! 

## The API

The following table describes the API endpoints. Each API requires an OAuth2 Bearer token.

API | Description
--- | -----------
`GET /api/v1/answers` | User retrieves all of their previous memes across all games
`GET /api/v1/answers/:id` | User retrieves only a single meme of theirs from a previous game
`PATCH /api/v1/answers/:id` | User updates a previous meme of theirs from a previous game
`PUT /api/v1/answers/:id` | User updates a previous meme of theirs from a previous game
`GET /api/v1/games/:game_id/answers` | User or client retrieves the memes of all players in the given game 
`POST /api/v1/games/:game_id/answers` | User submits a new meme, including image reference and captions
`POST /api/v1/games` | User starts a new game, optionally inviting friends
`GET /api/v1/users/:user_token_subject/answers` | User retrieves the memes shared by another user
`GET /api/v1/users/:user_token_subject/answers/:id` | User retrieves a single meme shared by another user

The following describes the `answer` resource, which is a meme created by a user.

Field | Type | Description
----- | ---- | -----------
`url` | URL  | Image URL (See the [Imgflip API](https://api.imgflip.com/) to get some ideas.)
`captions` | Array of Strings | User-generated captions
`rating` | Integer (optional) | Age rating for the meme

The following describes the `game` resource, when a user creates a new game.

Field | Type | Description
----- | ---- | -----------
`invitees` | Array of email addresses (optional) | Friends the user would like to join the game

The API format is [JSON:API](https://jsonapi.org/). 
Therefore, submitting a new meme looks like this:

`POST https://meme-game.com/api/v1/games/:game_id/answers`

```json
{
    "data": {
        "type": "answer",
        "attributes": {
            "url": "https://i.imgflip.com/c2qn.jpg",
            "captions": [
                "If you could go out and buy some more TP",
                "That'd be great"
            ]
        }
    }
}
```

Starting a new game looks like this:

`POST https://meme-game.com/api/v1/games`

```json
{
    "data": {
        "type": "game",
        "attributes": {
            "invitees": ["friend@example.com"]
        }
    }
}
```

## Shortcuts

This is a toy, after all, so I've taken several shortcuts in the API
to decrease the steps required to use each API
in order to focus on fine-grained access control use cases.

* There is effectively no built-in authorization:
  * _Don't submit anything sensitive!_
  * Any JWT access token with a `sub` attribute will do.
  * Even a "mock access token", like `Bearer {"sub": "username"}`
* You don't need to generate your own content, if you don't want:
  * `GET /api/v1/answers` will generate and return memes for your user.
  * Also, there's always a `user.0`. So, `GET /api/v1/users/user.0/answers` works all the time. 
* You don't need to `POST /api/v1/games` to create a game. `POST /api/v1/games/:game_id/answers` will create the game on-the-fly.
* While `GET`, `POST`, `PATCH` to `/api/v1/answers` will only access your calling user's meme, there is no real authorization (see first bullet). Don't get too attached to your masterful creation!
* `GET /api/v1/users/:user_token_subject/answers` enforces no sharing authorization. Don't create memes you don't want to share!
* Creating a new game with `invitees` will not store the email addresses nor email any invitees.

# Building and Running

### The easy way - On Heroku

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

### The harder way - On your Mac

Here's a crash course on running a Rails API on your Mac.

1. Install Homebrew because you're going to need PostgreSQL.
1. Install RVM to help you install Ruby.
1. Brew install PostgreSQL 12.2
1. RVM install Ruby 2.6.5
1. Create a gemset to isolate this app's gems.
1. Install the gems required by this app into that gemset.
1. Create the database.
1. Start your server.

Here's the script:

```bash
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
\curl -sSL https://get.rvm.io | bash -s stable --ruby
. ~/.rvm/scripts/rvm
brew install postgresql
pg_ctl -D /usr/local/var/postgres start
rvm install ruby-2.6.5
cd /path/to/cloned/repo
rvm gemset create meme-game
rvm use ruby-2.6.5@meme-game
bundle
rake db:setup
rails s
```

### The DIY way -- On your non-Mac

All of this stuff works on other operating systems. Good luck with that. 
