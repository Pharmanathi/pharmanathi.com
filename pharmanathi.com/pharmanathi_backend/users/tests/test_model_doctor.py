from datetime import datetime

import pytest

pytestmark = pytest.mark.django_db


def test_get_busy_slots_with_paid_appointment(doctor_with_appointment_random):
    """should include timeslot in busy slots"""
    doctor = doctor_with_appointment_random
    appointment = doctor.get_upcoming_appointments(include_pending_payments=True).first()
    appintment_time_slot_repr = appointment.timeslot_repr  # Something like ("09:30", "10:00")
    appointment_dt: datetime = appointment.start_time
    payment = appointment.payment
    payment.set_status_paid(save=True)
    assert (appintment_time_slot_repr) in doctor.get_busy_slots_on(appointment_dt.date())


def test_get_busy_slots_with_pending_payment(doctor_with_appointment_random):
    """should include the appointment's timeslot in the busy slots"""
    doctor = doctor_with_appointment_random
    appointment = doctor.get_upcoming_appointments(include_pending_payments=True).first()
    payment = appointment.payment
    payment.set_status_pending(save=True)
    appintment_time_slot_repr = appointment.timeslot_repr
    appointment_dt: datetime = appointment.start_time
    assert (appintment_time_slot_repr) in doctor.get_busy_slots_on(appointment_dt.date())


def test_get_busy_slots_with_unpaid_appointment(doctor_with_appointment_random):
    """should **NOT** include the appointment's timeslot in the busy slots"""
    doctor = doctor_with_appointment_random
    appointment = doctor.get_upcoming_appointments(include_pending_payments=True).first()
    payment = appointment.payment
    payment.set_status_failed(save=True)
    appintment_time_slot_repr = appointment.timeslot_repr
    appointment_dt: datetime = appointment.start_time
    assert (appintment_time_slot_repr) not in doctor.get_busy_slots_on(appointment_dt.date())


def test_get_available_slots_on(timeslot_9_to_10_am, build_future_date):
    timeslot = timeslot_9_to_10_am
    # Ensure related doctors has no appointments
    doctor = timeslot.doctor
    doctor.appointment_set.all().delete()
    assert {("09:00", "09:30"), ("09:30", "10:00")} == doctor.get_available_slots_on(
        build_future_date(timeslot.day), 30
    )
