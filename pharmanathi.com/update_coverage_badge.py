# TODO(nehemie): replace this whole script with `sed`
import sys
from typing import Union

PATH_MAIN_README = "../README.md"
COVERAGE_LINE_START = "![coverage]"


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
    assert len(sys.argv) > 1, "Please supply coverage percentage"
    coverage_percentage = sanitize(sys.argv[1])
    with open(PATH_MAIN_README, "r+") as f:
        lines = f.readlines()
        line_number = find_line_starting_with(COVERAGE_LINE_START, lines)
        if line_number:
            f.seek(0)
            lines[
                line_number
            ] = f"![coverage](https://img.shields.io/badge/coverage-{coverage_percentage}%25-{get_color_name(int(coverage_percentage))})\n"
            f.writelines(lines)
        else:
            raise ValueError(f"Could not find line starting with `{COVERAGE_LINE_START}` in {PATH_MAIN_README}")
