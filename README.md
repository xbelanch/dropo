# dropo

A simple and dumb tool that collects and parse data from IOC courses thanks to [Selenium](https://www.selenium.dev/) and [Ruby](https://www.ruby-lang.org/en/).

## What do you need before start

You must install [google-chrome](https://www.google.com/chrome/) on your system and `chromedriver` binary on the `vendor` directory. You can get it from [here](https://chromedriver.storage.googleapis.com/index.html). It's mandatory both versions are equal in order to run.

## Usage

``` shell
$ ruby dropo.rb <usename> <password> '['<course_id0>', '<course_id1>',...]'
```
