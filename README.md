# README

## Jason LaCarrubba's URL Shortener
This is a Rails app for shortening URLs. The app is built on top of Docker and uses Postgres as a datastore.

### Install:

[Docker For Mac](https://download.docker.com/mac/stable/Docker.dmg)

### Ruby version
2.5.0

### Rails Version
5.1.5

### Build and Run
From the project's root directory: 

`./scripts/build.sh`

In one terminal window run: 

`./scripts/run.sh`

**Leave the app running in the this terminal window!**

### Database Creation and Migration
In a 2nd terminal window run: 

`./scripts/db_create.sh`

Then: 

`./scripts/db_migrate.sh`

### Tests
`./scripts/test.sh`

### Usage
[Tye Me](http://localhost:3000/)

