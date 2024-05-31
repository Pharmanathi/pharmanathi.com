"""
Simple script for syncing the list of MHP speciliaties
"""

from ..models import Speciality

LIST_OF_SPECIALITIES = (
    (1, "DERM", "Dermatologist"),
    (2, "NEUR", "Neurologist"),
    (3, "CARD", "Cardiologist"),
    (4, "ORTH", "Orthopedic Surgeon"),
    (5, "PEDI", "Pediatrician"),
    (6, "PSYC", "Psychiatrist"),
    (7, "OBGY", "Obstetrician-Gynecologist"),
    (8, "ENT", "Otolaryngologist"),
    (9, "OPHTH", "Ophthalmologist"),
    (10, "ONC", "Oncologist"),
    (11, "ENDO", "Endocrinologist"),
    (12, "UROL", "Urologist"),
    (13, "GAST", "Gastroenterologist"),
    (14, "PLAS", "Plastic Surgeon"),
    (15, "RHEUM", "Rheumatologist"),
    (16, "ALLR", "Allergist/Immunologist"),
    (17, "PULM", "Pulmonologist"),
    (18, "NURSE", "Nurse Practitioner"),
    (19, "PHAR", "Pharmacist"),
    (20, "DIET", "Dietitian"),
    (21, "EMED", "Emergency Medicine Physician"),
    (22, "RADI", "Radiologist"),
    (23, "NURO", "Nurse Anesthetist"),
    (24, "PATH", "Pathologist"),
    (25, "OCCP", "Occupational Therapist"),
    (26, "PHYS", "Physical Therapist"),
    (27, "RESP", "Respiratory Therapist"),
    (28, "SOCW", "Social Worker"),
    (29, "PHED", "Physical Education Instructor"),
    (30, "CHIR", "Chiropractor"),
    (31, "RADT", "Radiation Therapist"),
    (32, "ORTT", "Orthotist"),
    (33, "OPTO", "Optometrist"),
    (34, "DENT", "Dentist"),
    (35, "PODI", "Podiatrist"),
    (36, "PHARMT", "Pharmacy Technician"),
    (37, "PERF", "Perfusionist"),
    (38, "NEPH", "Nephrologist"),
    (39, "VASC", "Vascular Surgeon"),
    (40, "NEURS", "Neurosurgeon"),
)


def run():
    for speciality in LIST_OF_SPECIALITIES:
        Speciality.objects.get_or_create(id=speciality[0], defaults={"symbol": speciality[1], "name": speciality[2]})
