// dropo.js
console.log("dropo.js")

const {Builder} = require('selenium-webdriver');
const chrome = require('selenium-webdriver/chrome');

const service = new chrome.ServiceBuilder('./vendor/chromedriver');
const driver = new Builder().forBrowser('chrome').setChromeService(service).build();

driver.get('https://ioc.xtec.cat');
let title = driver.getTitle();
console.log(title)
