# TODO(nehemie): replace this whole script with `sed`
import argparse
import sys
from typing import Union

PATH_MAIN_README = "../README.md"
GITHUB_WORKFLOW_LINK = "(https://github.com/Pharmanathi/pharmanathi.com/actions/workflows/ci.yml?query=branch%3Amain)"

parser = argparse.ArgumentParser()
parser.add_argument("-p", "--percentage", required=True)
parser.add_argument(
    "--starting-with", help="The reference text to use. The line starting this way will be updated", required=True
)
parser.add_argument("--badge-text", help="Text to display on the badge", required=True)


def find_line_starting_with(phrase: str, lines) -> int | None:
    for index, line in enumerate(lines):
        if phrase in line and line.index(phrase) == 0:
            return index

    return None


def get_color_name(value: int) -> str:
    if value > 80:
        return "brightgreen"

    if value > 75:
        return "yellow"

    return "red"


def sanitize(arg: str) -> str:
    return arg.strip()


if __name__ == "__main__":
    args = parser.parse_args()
    coverage_percentage = sanitize(args.percentage)
    with open(PATH_MAIN_README, "r+") as f:
        lines = f.readlines()
        line_number = find_line_starting_with(args.starting_with, lines)
        if line_number:
            f.seek(0)
            lines[
                line_number
            ] = f"{args.starting_with}(https://img.shields.io/badge/{args.badge_text}-{coverage_percentage}%25-{get_color_name(int(coverage_percentage))})]{GITHUB_WORKFLOW_LINK}\n"
            f.writelines(lines)
        else:
            raise ValueError(f"Could not find line starting with `{args.starting_with}` in {PATH_MAIN_README}")
