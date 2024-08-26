from os import environ

from flask import Flask, jsonify, request
from selenium import webdriver
from selenium.webdriver.chrome.options import Options as ChromeOptions
from verifi import get_logs, log
from verifi.providers import hpcsa, sapc

app = Flask(__name__)
SELENIUM_GRID_HOST = "web-driver"


def get_driver() -> webdriver.remote.webdriver.WebDriver:
    options = ChromeOptions()
    driver = webdriver.Remote(options=options, command_executor="http://web-driver:4444")
    return driver


@app.route("/", methods=["GET"])
def verify():
    """This utility heavily relies on the request arguments it receives.
    The arguments `id` and `type` are compulsory and must be correct.
    """
    identifier = request.args.get("id", None)
    first_name = request.args.get("first_name", None)
    last_name = request.args.get("last_name", None)
    mp_type = request.args.get("mp_type", None)

    if identifier is None:
        return jsonify({"detail": "Missing or invalid `id` request argument"}), 400

    if first_name is None:
        return jsonify({"detail": "Missing or invalid `first_name` request argument"}), 400

    if last_name is None:
        return jsonify({"detail": "Missing or invalid `last_name` request argument"}), 400

    if mp_type is None or (mp_type := mp_type.upper()) not in ["SAPC", "HPCSA"]:
        return (
            jsonify(
                {"detail": ("Missing or invalid `mp_type` request argument. It must be one of `SAPC` or `HPCSA`")}
            ),
            400,
        )

    driver = get_driver()
    driver.set_page_load_timeout(environ.get("VERIFI_GLOBAL_SOFT_LIMIT", 300))
    data = None

    try:
        verification_func = None
        if mp_type == "SAPC":
            verification_func = sapc.process
        else:
            verification_func = hpcsa.process

        log(f"Starting collection using {identifier, first_name, last_name} with method {mp_type}")
        data = verification_func(driver, identifier, first_name, last_name)
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
    data["_logs"] = get_logs()
    return jsonify(data)
