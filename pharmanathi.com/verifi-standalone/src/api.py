import datetime

from flask import Flask, jsonify, request
from selenium import webdriver
from selenium.webdriver.chrome.options import Options as ChromeOptions
from selenium.webdriver.common.by import By

app = Flask(__name__)
SELENIUM_GRID_HOST = "web-driver"


@app.route("/", methods=["GET"])
def verify():
    """This utility heavily relies on the request arguments it receives.
    The arguments `id` and `type` are compulsory and must be correct.
    """
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

        data = verification_func(driver, identifier)
    except Exception as e:
        print(e)
        return (
            jsonify({"detail": "An error occured on my side. Please try again later."}),
            500,
        )
    finally:
        driver.quit()

    return jsonify(data)


def process_sapc(driver, identifier):
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
        "_logs": [],
    }

    def log(text):
        """Allows for tracing this verification by aggregating logs into the report[]"_logs"] object"""
        report.get("_logs").append(text)

    # Search matching stuff.
    driver.get("https://interns.pharma.mm3.co.za/SearchRegister")
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


def process_hpcsa(driver, identifier):
    """Get a MP credentials from HPCSA

    Args:
        driver: the remote web driver to use
        identifier (_type_): Expects an indetifier of the form `MT___N` where
            - ___ is 3 space characters, and
            - N is a string-formatted number, may start with 0.

        The identifier is of a particular form and
        any error causes an empty report back. This simply means we can count on an
        empty report to mean one of:
        - The MP provided an invalid registration number
        - The regustration number has no record.
        Because of the particular format foir the registration number expected by the
        Pharmacouncil endpoit used for verification, it may become at some point ne-
        cessary to ensure there's 3 empty space characters between MT and the rest of
        the registration number. This means that for an MP who has 2 registration numbers
        linked to their HPCSA profile such as "MT X" and "MT S X" where X is a numerical
        string, a query with "MT S X" would work well, but "MT X" will only work if
        there is 3 empty space characters between MT and X.
    """
    REQ_URL = f"https://hpcsaonline.custhelp.com/app/iregister_details/reg_number/{identifier}"
    driver.get(REQ_URL)
    registrations = []
    current_registration = []
    table_index = 1

    for table in driver.find_elements(By.TAG_NAME, "table"):
        titles = []

        for tr_index, tr in enumerate(table.find_elements(By.TAG_NAME, "tr")):
            cells = list(map(lambda cell: cell.text, tr.find_elements(By.TAG_NAME, "td")))
            if tr_index == 0:
                titles = cells
                continue
            else:
                registration_entry = {}
                for i in range(len(titles)):
                    registration_entry[titles[i]] = cells[i]
                current_registration.append(registration_entry)

        if table_index == 3:
            table_index = 1
            registrations.append(current_registration)
            current_registration = []

        table_index += 1

    return {
        "datetime": datetime.datetime.now().isoformat(),
        "identifier": identifier,
        "type": "HPCSA",
        "url": REQ_URL,
        "profile": {
            "names": driver.find_element(By.ID, "NAME").text,
            "city": driver.find_element(By.ID, "CITY").text,
            "province": driver.find_element(By.ID, "PROVINCE").text,
            "postal_code": driver.find_element(By.ID, "POSTCODE").text,
        },
        "registrations": registrations,
    }
