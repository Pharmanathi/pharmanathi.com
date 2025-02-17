# Generated by Django 5.0.7 on 2024-08-27 14:07

import django.db.models.deletion
from django.conf import settings
from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        ("appointments", "0001_initial"),
        ("payments", "0001_initial"),
        ("users", "0001_initial"),
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.AddField(
            model_name="appointment",
            name="doctor",
            field=models.ForeignKey(on_delete=django.db.models.deletion.PROTECT, to="users.doctor"),
        ),
        migrations.AddField(
            model_name="appointment",
            name="patient",
            field=models.ForeignKey(on_delete=django.db.models.deletion.PROTECT, to=settings.AUTH_USER_MODEL),
        ),
        migrations.AddField(
            model_name="appointment",
            name="payment",
            field=models.OneToOneField(on_delete=django.db.models.deletion.PROTECT, to="payments.payment"),
        ),
        migrations.AddField(
            model_name="appointmenttype",
            name="doctor",
            field=models.ForeignKey(on_delete=django.db.models.deletion.PROTECT, to="users.doctor"),
        ),
        migrations.AddField(
            model_name="appointment",
            name="appointment_type",
            field=models.ForeignKey(on_delete=django.db.models.deletion.PROTECT, to="appointments.appointmenttype"),
        ),
        migrations.AddField(
            model_name="rating",
            name="appointment",
            field=models.ForeignKey(on_delete=django.db.models.deletion.PROTECT, to="appointments.appointment"),
        ),
        migrations.AddField(
            model_name="rating",
            name="giver",
            field=models.ForeignKey(
                on_delete=django.db.models.deletion.CASCADE, related_name="giver", to=settings.AUTH_USER_MODEL
            ),
        ),
        migrations.AddField(
            model_name="rating",
            name="receiver",
            field=models.ForeignKey(
                on_delete=django.db.models.deletion.CASCADE, related_name="receiver", to=settings.AUTH_USER_MODEL
            ),
        ),
        migrations.AddField(
            model_name="timeslot",
            name="doctor",
            field=models.ForeignKey(on_delete=django.db.models.deletion.PROTECT, to="users.doctor"),
        ),
        migrations.AddConstraint(
            model_name="timeslot",
            constraint=models.UniqueConstraint(
                fields=("doctor", "day", "start_time", "end_time"), name="unique_timeslot_configuration"
            ),
        ),
        migrations.AddConstraint(
            model_name="timeslot",
            constraint=models.UniqueConstraint(
                fields=("doctor", "day", "start_time"), name="same_start_time_timeslot"
            ),
        ),
        migrations.AddConstraint(
            model_name="timeslot",
            constraint=models.UniqueConstraint(fields=("doctor", "day", "end_time"), name="same_ebd_time_timeslot"),
        ),
    ]
