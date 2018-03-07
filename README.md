Depbot
======

It's like [deppbot](https://deppbot.com) but with one less p and it actually works (most of the time)

## Install & Setup

1. Clone the repo to your computer.
2. Copy and update your `.env` file.
3. Run `bundle` to install all of those dependencies.

## Usage

```bash
$ ruby depbot.rb
```

What is happening:

- The `GITHUB_REPO` is cloned into `tmp`
- A `bundle update` command is run
- The diff is parsed to determine what, if anything changed
- The changes are commited
- A pull request is opened with a nice formatted message including changelogs (if found) for the updated gems

## Dev Notes

This was a spike to see if I could get it to work. It's nasty, and probably only works well for `scf`. There are LOTS of
opportunities for cleanup / testing which should be done if this lives past today.

Feedback or Bug Reports? Talk to @tneems

## License

Copyright 2018 Jordan Byron

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
