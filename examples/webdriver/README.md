# webdriver

Example of how to use the **Selenium WebDriver** _Python_ library to drive the **Chromium** browser.

> **Important**: this has been tested on **Debian 12** (_bookworm_).

```bash
sudo apt-get update && sudo apt-get install -y chromium python3-venv

# Link for downloading the ChromeDriver found here: https://googlechromelabs.github.io/chrome-for-testing/#stable
curl -fLO "https://edgedl.me.gvt1.com/edgedl/chrome/chrome-for-testing/$(chromium --product-version)/linux64/chromedriver-linux64.zip"
unzip chromedriver-linux64.zip

python3 -mvenv myvenv
myvenv/bin/python3 -mpip install 'selenium==4.*'

myvenv/bin/python3 - << 'EOF'
from selenium import webdriver
from selenium.webdriver.chrome.service import Service as ChromeService

service = ChromeService(executable_path='chromedriver-linux64/chromedriver')
with webdriver.Chrome(service=service) as driver:
    driver.get('https://www.example.com/')
    print(driver.title)
EOF
```

> **Note**: this example aims to be as complete as possible. However, if you don't download the ChromeDriver, Selenium should automatically recognize the browser version and download the correct one into `~/.cache/selenium/chromedriver`. See https://www.selenium.dev/documentation/selenium_manager/ for more information.

For a more complex example, see https://www.selenium.dev/documentation/webdriver/getting_started/first_script/
