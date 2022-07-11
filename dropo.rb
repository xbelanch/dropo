#!/usr/bin/env ruby

require "selenium-webdriver"
require "json"

# parse arguments
# @TODO: Handle with error args
# @TODO: Add support for json configs
# username, password, _courses = ARGV
# courses = JSON.parse(_courses)
file = File.read(ARGV[0])
credentials = JSON.parse(file)
username = credentials["username"]
password = credentials["password"]
courses  = credentials["courses"]

# setup and configure the driver to run in headless mode
service = Selenium::WebDriver::Service.chrome(path: './vendor/chromedriver')
options = Selenium::WebDriver::Chrome::Options.new
options.add_argument('--headless')
options.add_argument('--window-size=1280,1024') # interact with campus in desktop layout
driver = Selenium::WebDriver.for :chrome, service: service, options: options
driver.manage.timeouts.implicit_wait = 30
exception = Selenium::WebDriver::Error::NoSuchElementError
wait = Selenium::WebDriver::Wait.new(timeout: 30, interval: 5, message: 'Timed out after 30 sec', ignore: exception)

begin
  # Visit IOC site and login
  driver.get "https://ioc.xtec.cat"
  puts "[i]: #{driver.title}"
  puts "[i]: #{driver.current_url}"
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
  # my_campus = wait.until {
  #   list_courses = "/html/body/div[3]/div[3]/div/div/section[1]/div/aside/section/div/div/div[1]/div[2]/div/div/div[1]/div/ul"
  #   el = driver.find_element(:xpath, list_courses)
  #   el if el.displayed?
  # }

  # Visit a list of owned courses and take a screenshot of them
  for id_course in courses
     driver.get "https://ioc.xtec.cat/campus/course/view.php?id=#{id_course}"
     course = wait.until {
       el = driver.find_element(id: 'page-content')
       el if el.displayed?
     }
     title = driver.find_elements(tag_name: 'h1').first
     puts "[i]: Course: #{title.text}"

     # We're in! take one screenshot to prove it!
     # First of all, we get the actual page dimensions using javascript
     width  = driver.execute_script("return Math.max(document.body.scrollWidth, document.body.offsetWidth, document.documentElement.clientWidth, document.documentElement.scrollWidth, document.documentElement.offsetWidth);")
     height = driver.execute_script("return Math.max(document.body.scrollHeight, document.body.offsetHeight, document.documentElement.clientHeight, document.documentElement.scrollHeight, document.documentElement.offsetHeight);")
     # resize windows depending on its full size
     driver.manage.window.resize_to(width+100, height+100)
     # take one full page screenshot
     driver.save_screenshot("./screenshot_#{id_course}.png")

     # time to go forward. What if we parse all the whole activities and resources
     # from the section 0?
     section0_title = driver.find_element(:xpath, '//*[@id="section-0"]/div/h3')
     puts "[i]: Section title: #{section0_title.text}"
     section0_contents = driver.find_elements(:xpath, '//*[@id="section-0"]/div/ul/li')
     # Traverse all that bunch of crap, open it and take a picture

     # store urls of the contents
     url_pages = Array.new
     puts "[i]: Table of contents of this section:"
     puts "---------------------------------------"
     for url in driver.find_elements(:xpath, '//*[@id="section-0"]/div/ul/li')
       url_pages << url.find_element(tag_name: 'a').attribute('href')
       puts "- #{url.text}"
     end
     puts "---------------------------------------"

     # visit content page and take a picture
     for url in url_pages
       driver.get url
       puts "[i]: Taking a picture of #{driver.title} page"
       wait.until {
         el = driver.find_element(id: 'page-content')
         el if el.displayed?
       }
       # @TODO: Too much hackish!
       id_picture = driver.title.downcase.tr(" ","_").tr(
"ÀÁÂÃÄÅàáâãäåĀāĂăĄąÇçĆćĈĉĊċČčÐðĎďĐđÈÉÊËèéêëĒēĔĕĖėĘęĚěĜĝĞğĠġĢģĤĥĦħÌÍÎÏìíîïĨĩĪīĬĭĮįİıĴĵĶķĸĹĺĻļĽľĿŀŁłÑñŃńŅņŇňŉŊŋÒÓÔÕÖØòóôõöøŌōŎŏŐőŔŕŖŗŘřŚśŜŝŞşŠšſŢţŤťŦŧÙÚÛÜùúûüŨũŪūŬŭŮůŰűŲųŴŵÝýÿŶŷŸŹźŻżŽž",
"AAAAAAaaaaaaAaAaAaCcCcCcCcCcDdDdDdEEEEeeeeEeEeEeEeEeGgGgGgGgHhHhIIIIiiiiIiIiIiIiIiJjKkkLlLlLlLlLlNnNnNnNnnNnOOOOOOooooooOoOoOoRrRrRrSsSsSsSssTtTtTtUUUUuuuuUuUuUuUuUuUuWwYyyYyYZzZzZz")
       driver.save_screenshot("./screenshot_#{id_course}_#{id_picture}.png")
     end
  end

ensure
  driver.quit
end
