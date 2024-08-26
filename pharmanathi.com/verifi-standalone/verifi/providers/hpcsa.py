import datetime
from os import environ

from selenium import webdriver
from selenium.webdriver.common.by import By
from verifi import log

PROVIDER_NAME = "HPCSA"


def search_with_reg_no(driver: webdriver.remote.webdriver.WebDriver, reg_no):
    regno_input_field_id = "rn_iRegisterForm_27_registrationCodeNumber"
    driver.find_element(By.ID, regno_input_field_id).clear()
    driver.find_element(By.ID, regno_input_field_id).send_keys(reg_no.replace(" ", ""))

    driver.execute_script(
        "Array.from(document.querySelectorAll('button')).find(b=>b.innerText.indexOf('SEARCH') > -1).classList.add('target-btn')"
    )
    search_button = driver.find_element(By.CSS_SELECTOR, ".target-btn")
    webdriver.ActionChains(driver).click(search_button).pause(5).perform()
    script = """
    let tt_text = document.querySelector("#total_records_found").innerText;
    let total_records_found = parseInt(tt_text.substr(tt_text.indexOf(":") + 1));
    return total_records_found;
    """
    return driver.execute_script(script)


def search_with_names(driver: webdriver.remote.webdriver.WebDriver, first_name: str, last_name: str):
    """Search on the main page using name and surname
        TODO(nehemie): deprecate(remove)
    Args:
        surname (str)
        name (str)
    """

    first_name_input_field_id = "rn_iRegisterForm_27_fullName"
    driver.find_element(By.ID, first_name_input_field_id).clear()
    driver.find_element(By.ID, first_name_input_field_id).send_keys(first_name)

    last_name_input_field_id = "rn_iRegisterForm_27_surName"
    driver.find_element(By.ID, last_name_input_field_id).clear()
    driver.find_element(By.ID, last_name_input_field_id).send_keys(last_name)

    driver.execute_script(
        "Array.from(document.querySelectorAll('button')).find(b=>b.innerText.indexOf('SEARCH') > -1).classList.add('target-btn')"
    )
    search_button = driver.find_element(By.CSS_SELECTOR, ".target-btn")
    webdriver.ActionChains(driver).pause(3).click(search_button).pause(3).perform()
    script = """
    let tt_text = document.querySelector("#total_records_found").innerText;
    let total_records_found = parseInt(tt_text.substr(tt_text.indexOf(":") + 1));
    return total_records_found;
    """
    return driver.execute_script(script)


def walk_results(driver: webdriver.remote.webdriver.WebDriver, reg_no: str) -> str:
    """For each record found, check if registration number correspond
    until we find a match. This function will either return a link
    to the match's page or an empty string if none found!

    Args:
        reg_no (str): MP regristration number

    Returns:
        [str]: empy if no match.
    """

    script = """
    let regNo = arguments[0];
    let btnNext = Array.from(document.querySelectorAll("button")).find(btn => btn.innerText == "Next");

    let link = "";
    match = Array.from(document.querySelectorAll("tr")).find(tr => tr.querySelectorAll("td")[3]?.innerText.replaceAll(" ", "") == regNo);
    if(match) {
        link = Array.from(match.querySelectorAll("td"))[7].querySelector("a").href;
    }
    return link;
    """
    return driver.execute_script(script, reg_no.replace(" ", ""))


def collect_info(driver: webdriver.remote.webdriver.WebDriver, reg_no: str, record_url: str) -> dict:
    """We only need to check if there exist any registration that
    is still active. Hence, only concerned with info under divs with
    class name "category". From this, we can extract each registration
    category that is active or inactive Also, the site is badly designed,
    they have titles in <tbody> so we always ignore the first table row.

    Args:
        reg_no (str): MP regristration number

    Returns:
        dict: scrapping result
    """
    script = """
    titles = ["PRACTICE TYPE",	"PRACTICE FIELD","SPECIALITY","SUB SPECIALITY","FROM DATE","END DATE","STATUS"]
    registration_rows = Array.from(document.querySelectorAll(".category tbody tr")).filter(tr => !Array.from(tr.querySelectorAll("td")).some(td => td.innerText == "STATUS"))
    return registration_rows.map(row =>{
        cells = row.querySelectorAll("td")

        return {
        "PRACTICE TYPE": cells[0].innerText,
        "PRACTICE FIELD": cells[1].innerText,
        "SPECIALITY": cells[2].innerText,
        "SUB SPECIALITY": cells[3].innerText,
        "FROM DATE": cells[4].innerText,
        "END DATE": cells[5].innerText,
        "STATUS": cells[6].innerText
    }})
    """

    return {
        "datetime": datetime.datetime.now().isoformat(),
        "identifier": reg_no,
        "type": "HPCSA",
        "url": record_url,
        "profile": {
            "names": driver.find_element(By.ID, "NAME").text,
            "city": driver.find_element(By.ID, "CITY").text,
            "province": driver.find_element(By.ID, "PROVINCE").text,
            "postal_code": driver.find_element(By.ID, "POSTCODE").text,
        },
        "registrations": driver.execute_script(script),
    }


def process(
    driver: webdriver.remote.webdriver.WebDriver, registration_no: str, first_name: str, last_name: str
) -> dict:
    """Get a MP credentials from HPCSA"""
    ENTRY_URL = environ.get("HPCSA_ENTRY_URL", None)
    log(f"Using link {ENTRY_URL}")
    driver.get(ENTRY_URL)

    total_found = search_with_reg_no(driver, registration_no)
    if not total_found:
        log("Found nothing using registration number, trying with names")
        total_found = search_with_names(driver, first_name, last_name)

    log(f"Found {total_found} records")
    if total_found == 0:
        log(f"Found no records for {first_name} {last_name} {registration_no}")
        return {}

    record_page_url = walk_results(driver, registration_no)
    log(f"Found match with link {record_page_url}")

    if len(record_page_url) < 1:
        log(f"None of the {total_found} records matches the given registration number({registration_no})")
        return {}

    # if we got this far, go to link
    driver.get(record_page_url)
    data = collect_info(driver, registration_no, record_page_url)
    return data
