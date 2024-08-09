import matplotlib.pyplot as plt

# Function to read the points from "channel.vertex"
def read_points(file_path):
    with open(file_path, 'r') as file:
        data = file.readlines()
    num_points = int(data[0].strip())
    points = [tuple(map(float, line.strip().split())) for line in data[1:num_points+1]]
    return points

# Function to read the springs from "channel.spring"
def read_springs(file_path):
    with open(file_path, 'r') as file:
        data = file.readlines()
    num_springs = int(data[0].strip())
    springs = [tuple(map(int, line.strip().split()[:2])) for line in data[1:num_springs+1]]
    return springs

# Function to read targets from "channel.target"
def read_targets(file_path):
    with open(file_path, 'r') as file:
        data = file.readlines()
    num_targets = int(data[0].strip())
    targets = [int(line.strip().split()[0]) for line in data[1:num_targets+1]]
    return targets

# Function to read poroelastic points from "channel.poroelastic"
def read_poroelastic(file_path):
    with open(file_path, 'r') as file:
        data = file.readlines()
    num_poroelastic = int(data[0].strip())
    poroelastic = [int(line.strip().split()[0]) for line in data[1:num_poroelastic+1]]
    return poroelastic

# Load the data
points = read_points('channel.vertex')
springs = read_springs('channel.spring')
targets = read_targets('channel.target')
poroelastic = read_poroelastic('channel.poroelastic')

# Unpack the points into x and y values
x_values, y_values = zip(*points)

# Prepare data for plotting
spring_points = set([index for pair in springs for index in pair])  # All unique spring points
target_points = set(targets)
poroelastic_points = set(poroelastic)

# Create the plot
plt.figure(figsize=(10, 8))

# Plot all points
# plt.scatter(x_values, y_values, color='gray', marker='o', label='All Points', alpha=0.5)

# Plot springs
spring_x = [x_values[i-1] for i in spring_points]
spring_y = [y_values[i-1] for i in spring_points]
# plt.scatter(spring_x, spring_y, color='blue', marker='x', label='Springs', s=100)

# Draw lines between spring pairs
for point_id1, point_id2 in springs:
    x_coords = [x_values[point_id1-1], x_values[point_id2-1]]
    y_coords = [y_values[point_id1-1], y_values[point_id2-1]]
    plt.plot(x_coords, y_coords, color='blue', linestyle='-', linewidth=1)

# Plot targets
target_x = [x_values[i-1] for i in target_points]
target_y = [y_values[i-1] for i in target_points]
# plt.scatter(target_x, target_y, color='red', marker='s', label='Targets', s=100)

# Plot poroelastic points
poroelastic_x = [x_values[i-1] for i in poroelastic_points]
poroelastic_y = [y_values[i-1] for i in poroelastic_points]
# plt.scatter(poroelastic_x, poroelastic_y, color='green', marker='^', label='Poroelastic', s=100)

# Add labels and title
plt.xlabel('X-axis')
plt.ylabel('Y-axis')
plt.title('Overlay of Springs, Targets, and Poroelastic Points with Spring Connections')
plt.legend()
plt.grid(True)

# Show the plot
plt.show()