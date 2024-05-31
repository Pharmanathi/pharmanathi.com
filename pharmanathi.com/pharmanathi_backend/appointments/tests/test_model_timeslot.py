import pytest

pytestmark = pytest.mark.django_db


def test_break_into_slots_of(timeslot_9_to_10_am):
    assert timeslot_9_to_10_am.break_into_slots_of(30) == [("09:00", "09:30"), ("09:30", "10:00")]
