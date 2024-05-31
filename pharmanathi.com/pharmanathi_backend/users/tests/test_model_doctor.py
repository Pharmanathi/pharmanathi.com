from datetime import datetime

import pytest

pytestmark = pytest.mark.django_db


def test_get_busy_slots_on(doctor_with_appointment_random):
    doctor = doctor_with_appointment_random
    appointment = doctor.upcoming_appointments.first()
    appintment_time_slot_repr = appointment.timeslot_repr  # Something like ("09:30", "10:00")
    appointment_dt: datetime = appointment.start_time
    assert (appintment_time_slot_repr) in doctor.get_busy_slots_on(
        appointment_dt.date()
    )  # == doctor.upcoming_appointments.filter(start_time=appointment_dt).to_time_slots == [("")]


def test_get_available_slots_on(timeslot_9_to_10_am, build_future_date):
    timeslot = timeslot_9_to_10_am
    # Ensure related doctors has no appointments
    doctor = timeslot.doctor
    doctor.appointment_set.all().delete()
    assert {("09:00", "09:30"), ("09:30", "10:00")} == doctor.get_available_slots_on(
        build_future_date(timeslot.day), 30
    )
