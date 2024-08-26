import datetime
from os import environ

from selenium import webdriver
from selenium.webdriver.common.by import By
from verifi import log

PROVIDER_NAME = "SAPC"


def process(driver: webdriver.remote.webdriver.WebDriver, identifier, first_name: str, last_name: str):
    """Get a MP credentials from The South African Pharmacy Council

    Args:
        driver: the remote web driver to use
        identifier (_type_): Expects an indetifier of the form `MT___N` where
            - ___ is 3 space characters, and
            - N is a string-formatted number, may start with 0.

    Args:
        driver (webdriver): the remote web driver to use
        identifier (str): P Number

    """

    report = {
        "datetime": datetime.datetime.now().isoformat(),
        "identifier": identifier,
        "type": "SAPC",
        "registration": {},
    }

    # Search matching stuff.
    driver.get(environ.get("SAPC_ENTRY_URL", None))
    driver.find_element(By.CSS_SELECTOR, "#OnlineSearchTypeId[value='1']").click()
    driver.find_element(By.NAME, "SearchText").clear()
    driver.find_element(By.NAME, "SearchText").send_keys(identifier)
    search_button = driver.find_element(By.CSS_SELECTOR, "[value='Search']")
    webdriver.ActionChains(driver).click(search_button).pause(3).perform()

    # Check if there is any result matching the specified PNUMBER(identifier)
    search_result_table_first_td = driver.find_element(By.CSS_SELECTOR, "#myTable tr:last-child td")
    if "No records found" in search_result_table_first_td.text:
        # If no match, return an empty report
        log(f"Search for '{identifier}' returned no records")
        return report
    else:
        # Make sure the PNumber match
        if identifier not in search_result_table_first_td.text:
            log(f"Search for '{identifier}' returned non-matching PNumber: {search_result_table_first_td.text}")
            return report

        # If there is a match, proceed to the `view` page
        view_button = driver.find_element(By.CSS_SELECTOR, "#myTable tr:last-child td:last-child a")
        webdriver.ActionChains(driver).pause(3).click(view_button).pause(3).perform()

        # On the view page, go through the table and collect the data
        for tr in driver.find_elements(By.TAG_NAME, "tr"):
            report["registration"][tr.find_element(By.TAG_NAME, "th").text] = tr.find_element(By.TAG_NAME, "td").text

        report["url"] = str(driver.current_url)
        return report
