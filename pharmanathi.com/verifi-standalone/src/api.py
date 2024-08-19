import datetime
from os import environ
from typing import Union

from flask import Flask, jsonify, request
from selenium import webdriver
from selenium.webdriver.chrome.options import Options as ChromeOptions
from selenium.webdriver.common.by import By

app = Flask(__name__)
SELENIUM_GRID_HOST = "web-driver"

logs = []


def log(text):
    """Allows for tracing this verification by aggregating logs into the report[]"_logs"] object"""
    logs.append(f"{datetime.datetime.now().strftime('[%D/%b/%Y %H:%M:%S]')} {text}")


@app.route("/", methods=["GET"])
def verify():
    """This utility heavily relies on the request arguments it receives.
    The arguments `id` and `type` are compulsory and must be correct.
    """
    identifier = request.args.get("id", None)
    first_name = request.args.get("first_name", None)
    last_name = request.args.get("last_name", None)
    identifier = request.args.get("id", None)
    mp_type = request.args.get("type", None)

    if identifier is None:
        return jsonify({"detail": "Missing or invalid `id` request argument"}), 400

    if mp_type is None or mp_type not in ["SAPC", "HPCSA"]:
        return (
            jsonify(
                {"detail": ("Missing or invalid `type` request argument. " "It must be one of `SAPC` or `HPCSA`")}
            ),
            400,
        )

    options = ChromeOptions()
    driver = webdriver.Remote(options=options, command_executor="http://web-driver:4444")

    driver.set_page_load_timeout(300)
    data = None

    try:
        verification_func = None
        if mp_type == "SAPC":
            verification_func = process_sapc
        elif mp_type == "HPCSA":
            verification_func = process_hpcsa
        else:
            raise ValueError(f"Invalid value for request({mp_type})")

        log(f"Starting collection with {identifier, first_name, last_name, identifier} using {mp_type}")
        data = verification_func(driver, identifier, first_name, last_name, identifier)
    except Exception as e:
        error_message = jsonify({"error": f"Implementation Error: {str(e)}"})
        log(error_message)
        return (
            error_message,
            500,
        )
    finally:
        driver.quit()

    log(f"Done!")
    data["_logs"] = logs
    return jsonify(data)


def process_sapc(driver: webdriver.remote.webdriver.WebDriver, identifier):
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


def process_hpcsa(
    driver: webdriver.remote.webdriver.WebDriver, registration_no: str, first_name: str, last_name: str, reg_no: str
) -> dict:
    """Get a MP credentials from HPCSA"""
    ENTRY_URL = environ.get("HPCSA_ENTRY_URL", None)
    log(f"Using link {ENTRY_URL}")
    driver.get(ENTRY_URL)

    def search_with_reg_no(reg_no):
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

    def search_with_names(first_name: str, last_name: str):
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

    def walk_results(registration_no: str) -> str:
        """For each record found, check if registration number correspond
        until we find a match. This function will either return a link
        to the match's page or an empty string if none found!

        Args:
            registration_no (str): MP regristration number

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
        return driver.execute_script(script, registration_no.replace(" ", ""))

    def collect_info(reg_no: str, record_url: str) -> dict:
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

    total_found = search_with_reg_no(reg_no)

    log(f"Found {total_found} records")
    if total_found == 0:
        err_message = f"Found no records for {first_name} {last_name} {reg_no}"
        log(err_message)
        return {}

    record_page_url = walk_results(registration_no)
    log(f"Found match with link {record_page_url}")

    if len(record_page_url) < 1:
        err_message = f"None of the {total_found} records matches the given registration number({reg_no})"
        log(err_message)
        return {}

    # go to link
    driver.get(record_page_url)
    data = collect_info(reg_no, record_page_url)
    return data
