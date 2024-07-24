import math
import matplotlib.pyplot as plt

# Number of points
num_mantle_points = 30
num_siphon_points = 20
num_siphon2_points = 10
num_points = num_mantle_points + num_siphon_points + num_siphon2_points
body_length = 1

def rd(k):
    return round(k, 8)

# File path
path = "squid_body.vertex"
file = open(path, 'w')

# Write the total number of points
file.write(str(num_points) + '\n')

# Calculate and write mantle points
y_start = 5.75
y_end = 14.25
y_values = [y_start + i * (y_end - y_start) / (num_mantle_points - 1) for i in range(num_mantle_points)]

for i, y in enumerate(y_values):
    x = -(y - 10)**2 + 32
    x = rd(x)
    y = rd(y)
    file.write(f"{x} {y}")
    if i < num_mantle_points - 1 or num_siphon_points > 0:
        file.write('\n')

# Calculate and write siphon points
x_start = 15
x_end = 7
x_values = [x_start + i * (x_end - x_start) / (num_siphon_points - 1) for i in range(num_siphon_points)]

for i, x in enumerate(x_values):
    y = 6.2 / (1 + math.exp(-x+10)) + 6.8
    x = rd(x)
    y = rd(y)
    file.write(f"{x} {y}")
    file.write('\n')

x_start = 7
x_end = 15
x_values_siphon2 = [x_start + i * (x_end - x_start) / (num_siphon2_points - 1) for i in range(num_siphon2_points)]

for i, x in enumerate(x_values_siphon2):
    y = 7
    x = rd(x)
    y = rd(y)
    file.write(f"{x} {y}")
    if i < num_siphon2_points - 1:
        file.write('\n')
        
file.close()

def read_points(file_path):
    points = []
    with open(file_path, 'r') as file:
        num_points = int(file.readline().strip())
        for line in file:
            x, y = map(float, line.strip().split())
            points.append((x, y))
    return points


# Read points
points = read_points("squid_body.vertex")

# Separate x and y coordinates
x_coords = [p[0] for p in points]
y_coords = [p[1] for p in points]

# Plot points
plt.figure(figsize=(10, 6))
plt.scatter(x_coords, y_coords, c='blue', marker='o')
plt.title('Visualization of Points')
plt.xlabel('X')
plt.ylabel('Y')
plt.grid(True)
plt.show()