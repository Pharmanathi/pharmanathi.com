from django.contrib import admin

from . import models

admin.site.register(models.AppointmentType)
admin.site.register(models.Appointment)
admin.site.register(models.TimeSlot)
