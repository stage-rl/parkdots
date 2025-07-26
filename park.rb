# This sample code supports Appium Ruby lib core client >=5
# gem install appium_lib_core
# Then you can paste this into a file and simply run with Ruby

require 'appium_lib'

current_time = Time.now
return if current_time.saturday? || current_time.sunday?

caps = {}
caps["platformName"] = "Android"
caps["appium:automationName"] = "UiAutomator2"
caps["appium:ensureWebviewsHavePages"] = true
caps["appium:nativeWebScreenshot"] = true
caps["appium:newCommandTimeout"] = 3600
caps["appium:connectHardwareKeyboard"] = true

def set_time(current_time)
  hour = current_time.hour
  10.times do |x|
    el7 = driver.find_element :uiautomator, "new UiSelector().text(\"#{hour + x}\")"
    el7.click
  end
end

def swipe_to_pay(driver, button)
  button_location = button.location
  button_size = button.size

  # Calculate start and end coordinates for the swipe
  # Start slightly from the left edge of the element, centered vertically
  start_x = button_location.x + (button_size.width * 0.1) # 10% in from left
  start_y = button_location.y + (button_size.height / 2)

  # End point: move to the right, keeping the same y
  # You might adjust this based on how far you want to swipe.
  # Here, we'll swipe to 90% of the screen width.
  screen_width = button_size.width
  end_x = screen_width * 0.8
  duration_ms = 500

  # Create and perform the touch action
  action = Appium::TouchAction.new(driver)
  action
    .press(x: start_x, y: start_y)
    .wait(duration_ms)
    .move_to(x: end_x, y: start_y)
    .release
    .perform
end
def run_test(caps)
  begin
    core = Appium::Core.for url: "http://127.0.0.1:4723", caps: caps
    driver = core.start_driver
    driver.terminate_app("com.parkdots.sp")
    sleep 2
    driver.activate_app("com.parkdots.sp")
    sleep 2
    el1 = driver.find_element :id, "android:id/button2"
    el1.click
    el2 = driver.find_element :id, "com.parkdots.sp:id/text_search"
    el2.click
    driver.save_screenshot("screenshot.png")
    el3 = driver.find_element :id, "com.parkdots.sp:id/editSearch"
    el3.click
    el3.send_keys "hodzovo"
    el4 = driver.find_element :uiautomator, "new UiSelector().text(\"1101 - Hodžovo námestie\")"
    el4.click
    driver.save_screenshot("screenshot.png")
    el5 = driver.find_element :accessibility_id, "Buy ticket"
    el5.click
    el6 = driver.find_element :id, "com.parkdots.sp:id/text_parking_duration_subtitle"
    el6.click
    set_time(current_time)
    swipe_to_pay_button = driver.find_element :uiautomator, "new UiSelector().text(\"SWIPE TO PAY\")"
    swipe_to_pay(driver, swipe_to_pay_button)
  rescue => e # Catch any exception
      puts "Test failed with error: #{e.message}"

      # Define screenshot path
      screenshot_dir = File.expand_path('./screenshots', __dir__) # Relative to current file
      FileUtils.mkdir_p(screenshot_dir) unless File.directory?(screenshot_dir)

      # Create unique filename
      timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
      screenshot_name = "screenshot_#{timestamp}.png"
      screenshot_path = File.join(screenshot_dir, screenshot_name)

      begin
        driver.save_screenshot(screenshot_path)
        puts "Screenshot saved to: #{screenshot_path}"
      rescue Selenium::WebDriver::Error::WebDriverError => screenshot_err
        puts "WARNING: Could not take screenshot: #{screenshot_err.message}"
      rescue StandardError => unexpected_err
        puts "WARNING: An unexpected error occurred while saving screenshot: #{unexpected_err.message}"
      end

      # Re-raise the original exception so the test framework knows it failed
      raise e

    ensure
      # This block always runs, whether there's an error or not.
      # Good place to quit the driver if you're managing it per test.
      if defined?(driver) && driver.is_a?(Selenium::WebDriver::Driver) && driver.session_id
        puts "Quitting driver after test: #{test_name}"
        driver.quit
      end
  end
end

run_test(caps)