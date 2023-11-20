import re
import csv

file_path = "./results/results-arb-nucleus-decomp-cpu-18859369.txt"

results = []

with open(file_path, "r") as file:
    line = file.readline()
    while line:
        line = line.strip()
        
        if re.match(r"Benchmarking graph .*\.txt started", line):
            entry = {}
        elif  re.match(r"Benchmarking graph .*\.txt finished\.", line): 
            results.append(entry)
            entry = None
        elif line.startswith("### "):
            line = line[4:]
            parts = line.split(": ")
            if len(parts) == 2:
                entry[parts[0]] = parts[1]
        
        line = file.readline()


with open('results/results.csv', 'w', newline='') as csvfile:
    fieldnames = results[0].keys() if results else []
    writer = csv.DictWriter(csvfile, fieldnames=fieldnames)

    writer.writeheader()
    for row in results:
        writer.writerow(row)
