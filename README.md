GemDandy
========

[![Build Status](https://travis-ci.com/SeeClickFix/gem_dandy.svg?token=qZH3VyhDsFzTvXX96D9s&branch=master)](https://travis-ci.com/SeeClickFix/gem_dandy)

> "It's a bot for your Gemfile. What could go wrong" -- @tneems

![bots making Gemfiles](https://media3.giphy.com/media/bzNZW2FTwsNQA/giphy.gif)

GemDandy automates your `bundle update` workflow ensuring your project always has the latest and greatest gems
installed. 

![Pull Request](https://i.imgur.com/Hwn3KiU.png)

If your Gemfile needs updates, GemDandy will submit a beautifully formated pull request and show you the changes that
are being made, including git diffs and change logs for gems that have them!

## Install & Setup

1. Clone the repo to your computer.
2. Copy and update your `.env` file.
3. Run `bundle` to install all of those dependencies.

## Local Usage

```bash
$ bin/gem_dandy <github_user>/<github_repo> [options]
```

What is happening:

- The repo is cloned into `tmp`
- A `bundle lock --update` command is run
- The diff is parsed to determine what, if anything changed
- The changes are commited
- A pull request is opened with a nice formatted message including changelogs (if found) for the updated gems

You can do the clone, update, and generate the pull-request text without committing and pushing to github by adding the
`--dry-run` option when calling `bin/gem_dandy`

You can also change the base branch from `master` to something else using the `-b <branch>` flag.

## Automating updates with Heroku

GemDandy can be setup to run automatically on a free Heroku dyno :metal:

- First, setup a new Heroku project
- Add the environment variables in `.env.example` using `heroku config:set`
- Push the code to Heroku
- Add the free [Heroku Scheduler](https://elements.heroku.com/addons/scheduler) to your project
- Add a new job to run `rake heroku:update` every day

GemDandy will check all repos listed in `REPOS_TO_UPDATE` and create a new pull request if there are any updates.

Review the comments in `.env.example` for caveats about updating private gems and adding GitHub's servers to the
`known_hosts` file.

You can check that the update command is working as expected by running `$ heroku run rake heroku:update` locally.

## License

Copyright 2018 Jordan Byron

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
