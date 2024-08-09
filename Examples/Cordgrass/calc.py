import glob
import os
import csv

def process_vtk_file(filename):
    with open(filename, 'r') as file:
        lines = file.readlines()

    # Find the line containing "SCALARS uY double"
    start_idx = -1
    for i, line in enumerate(lines):
        if "SCALARS uX double" in line:
            start_idx = i + 2  # Data starts two lines after this
            break

    if start_idx == -1:
        print(f"SCALARS uX double not found in {filename}")
        return None

    # Extract data from the file
    data_lines = lines[start_idx:]

    # Process each line to sum the last 45% and calculate the average
    total_sum = 0
    total_count = 0

    for line in data_lines:
        values = list(map(float, line.split()))
        num_values = len(values)
        start_index = int(num_values * 0.55)  # Start from 55% to get the last 45% 0.55 instead of 0

        partial_sum = sum(values[start_index:])
        partial_count = num_values - start_index

        total_sum += partial_sum
        total_count += partial_count

    if total_count > 0:
        average = total_sum / total_count
        # print(f"{filename}: Average of last 45% = {average:.6f}")
        return average
    else:
        # print(f"{filename}: No data to process.")
        return None

# Set the directory path
directory_path = "trials/14"

# List to hold the filename and its corresponding average
file_averages = []
 
# Process all files matching the pattern uX.????.vtk in the specified directory
for filename in glob.glob(os.path.join(directory_path, "uX.[0-1][0-9][0-9][0-9].vtk")):
    #print(f"Processing {filename}...")
    file_average = process_vtk_file(filename)
    if file_average is not None:
        # Extract the number from the filename (e.g., '0001' from 'uX.0001.vtk')
        file_number = os.path.splitext(os.path.basename(filename))[0].split('.')[1]
        file_averages.append((file_number, file_average))

# Calculate the overall average of all file averages
if file_averages:
    overall_average = sum([avg for _, avg in file_averages]) / len(file_averages)
    print(f"Overall Average of all file averages = {overall_average:.8f}")

    # Export to a CSV file
    csv_filename = "file_averages.csv"
    with open(csv_filename, 'w', newline='') as csvfile:
        csvwriter = csv.writer(csvfile)
        csvwriter.writerow(["File Number", "Average"])  # Header row
        csvwriter.writerows(file_averages)  # Data rows

    #print(f"File averages saved to {csv_filename}.")
else:
    print("No valid file averages to process.")