import csv
import json

input_file = "filament_catalog.csv"
output_file = "filament_catalog.json"

data = []

with open(input_file, encoding="utf-8") as csvfile:
    reader = csv.DictReader(csvfile)

    for row in reader:
        brand = row["Hersteller"].strip()
        material = row["Material"].strip()
        variant = row["Variante"].strip()
        color = row["Farbe"].strip()

        data.append({
            "brand": brand,
            "material": material,
            "variant": variant,
            "color": color
        })

with open(output_file, "w", encoding="utf-8") as jsonfile:
    json.dump(data, jsonfile, indent=2, ensure_ascii=False)

print("JSON erstellt:", output_file)
print("Einträge:", len(data))