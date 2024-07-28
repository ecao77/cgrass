import os
import glob
import numpy as np

def is_numeric_line(line):
    return all(item.replace("e", "").replace("+", "").replace("-", "").replace(".", "").isdigit() for item in line.split())

def process_vtk_files(folder_path):
    file_pattern = os.path.join(folder_path, 'uX.????.vtk')
    vtk_files = sorted(glob.glob(file_pattern))

    results = []

    for file_path in vtk_files:
        with open(file_path, 'r') as file:
            data_started = False
            averages = []

            for line in file:
                line = line.strip()
                if not data_started:
                    if line.startswith("LOOKUP_TABLE default"):
                        data_started = True
                    continue

                if is_numeric_line(line):
                    numbers = [float(x) for x in line.split()]
                    if numbers:
                        last_quarter = numbers[int(3*len(numbers)/4):]
                        avg = sum(last_quarter) / len(last_quarter)
                        averages.append(avg)

            if averages:
                file_avg = sum(averages) / len(averages)
                results.append((os.path.basename(file_path), file_avg))
            else:
                print(f"Warning: No valid data found in {file_path}")

    return results

def main():
    folder_path = 'littletrials/control'
    results = process_vtk_files(folder_path)

    if results:
        print("File Averages:")
        # for file_name, avg in results:
            # print(f"{file_name}: {avg:.6e}")

        overall_avg = sum(avg for _, avg in results) / len(results)
        print(f"\nOverall Average: {overall_avg:.6e}")
    else:
        print("No valid results found.")

if __name__ == "__main__":
    main()