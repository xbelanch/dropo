#!/usr/bin/env ruby

require "selenium-webdriver"
require "webdrivers"
require "json"

# parse arguments
# 
username, password, _courses = ARGV
courses = JSON.parse(_courses)

# setup and configure the driver to run in headless mode
service = Selenium::WebDriver::Service.chrome(path: './vendor/chromedriver')
options = Selenium::WebDriver::Chrome::Options.new
options.add_argument('--headless')
options.add_argument('--window-size=1280,1024') # interact with campus in desktop layout
driver = Selenium::WebDriver.for :chrome, service: service, options: options
exception = Selenium::WebDriver::Error::NoSuchElementError
wait = Selenium::WebDriver::Wait.new(timeout: 30, interval: 5, message: 'Timed out after 30 sec', ignore: exception)

begin
  # Visit IOC site and login
  driver.get "https://ioc.xtec.cat"
  puts driver.title
  puts driver.current_url  
  login_button = wait.until {
    el = driver.find_element(:xpath, '//*[@id="login-campus-large"]')
    el if el.displayed?
  }
  login_button.click
  login_modal_form = wait.until {
    el = driver.find_element(:xpath, '/html/body/div[1]/section/div[1]/div/div/div/div[8]/div/div/div')
    el if el.displayed?
  }

  # Fill login form and submit
  driver.find_element(id: 'username').send_keys username
  driver.find_element(id: 'password').send_keys password
  # login_modal_form.save_screenshot('./login_form.png')
  driver.find_element(id: 'submitbutton').click

  # Wait until main page is loaded (fucking courses list!)
  my_campus = wait.until {
    list_courses = "/html/body/div[3]/div[3]/div/div/section[1]/div/aside/section/div/div/div[1]/div[2]/div/div/div[1]/div/ul"
    el = driver.find_element(:xpath, list_courses)
    el if el.displayed?
  }

  # Visit a list of owned courses and take a screenshot of them
  # id_courses = ['957', '11817', '11819', '11186', '11187']
  for id in courses
     driver.get "https://ioc.xtec.cat/campus/course/view.php?id=#{id}"
     course = wait.until {
       el = driver.find_element(id: 'page-content')
       el if el.displayed?
     }
     title = driver.find_elements(tag_name: 'h1').first
     puts title.text

     # We're in! take one screenshot to prove it!
     # First of all, we get the actual page dimensions using javascript
     width  = driver.execute_script("return Math.max(document.body.scrollWidth, document.body.offsetWidth, document.documentElement.clientWidth, document.documentElement.scrollWidth, document.documentElement.offsetWidth);")
     height = driver.execute_script("return Math.max(document.body.scrollHeight, document.body.offsetHeight, document.documentElement.clientHeight, document.documentElement.scrollHeight, document.documentElement.offsetHeight);")
     # resize windows depending on its full size
     driver.manage.window.resize_to(width+100, height+100)
     # take one full page screenshot
     driver.save_screenshot("./screenshot_#{id}.png")
  end
  
ensure
  driver.quit
end




