# Test Talon.One plugin for Solidus

This is the Solidus plugin for the promotion, coupon and referral egine [Talon.One](https://talon.one)
It makes use of the [Talon.One Ruby SDK](https://github.com/talon-one/talon_one.rb).
Detailed developer documentation is available at https://developers.talon.one. 

# Installation

## Make a Rails app
```
$ rails new myshop
$ cd myshop
```

## Make a Solidus shop
Follow the instructions on 

https://github.com/solidusio/solidus#getting-started

## Add and configure our plugin

1. Stop the runnning shop in case it is still running.

1. Append our plugin to your Gemfile  
     `gem 'solidus_talon_one'`

1. Configure the plugin with the following ENV variables, whose values are visible in your Talon.One campaign manager:  
    - `TALONONE_ENDPOINT`
    - `TALONONE_APP_ID`
    - `TALONONE_APP_KEY`  

1. Start the shop again  
    `$ bundle exec rails s`
