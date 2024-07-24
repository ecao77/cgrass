import numpy as np

def generate_points():
    # Generate 100 points evenly spaced between (0.05, 0.025) and (0.95, 0.025)
    x1 = np.linspace(0.05, 0.95, 100)
    y1 = np.full_like(x1, 0.025)
    points1 = np.column_stack((x1, y1))

    # Generate 3 points evenly spaced between (0.5, 0.025) and (0.5, 0.125)
    x2 = np.full(3, 0.5)
    y2 = np.linspace(0.025, 0.125, 3)
    points2 = np.column_stack((x2, y2))

    # Generate 100 points evenly spaced between (0.05, 0.225) and (0.95, 0.225)
    x3 = np.linspace(0.05, 0.95, 100)
    y3 = np.full_like(x3, 0.225)
    points3 = np.column_stack((x3, y3))

    # Combine all points
    all_points = np.vstack((points1, points2, points3))

    return all_points

def save_to_file(filename, points):
    num_points = len(points)
    with open(filename, 'w') as file:
        file.write(f"{num_points}\n")
        for i, point in enumerate(points):
            file.write(f"{point[0]:.16e} {point[1]:.16e}")
            if i < num_points - 1:
                file.write("\n")

def save_targets(filename, first_segment, second_segment, stiffness):
    with open(filename, 'w') as file:
        num_points = len(first_segment) + len(second_segment)
        file.write(f"{num_points}\n")
        for i, point_id in enumerate(first_segment + second_segment):
            file.write(f"{point_id} {stiffness}")
            if i < num_points - 1:
                file.write("\n")

def main():
    points = generate_points()
    save_to_file("channel.vertex", points)
    print("Points generated and saved to channel.vertex")

    # Point IDs 1 to 101 and then 104 to 203
    first_segment = list(range(1, 102))
    second_segment = list(range(104, 204))
    
    # Save targets with point IDs from 1 to 101 and 104 to 203, stiffness of 100000
    save_targets("channel.target", first_segment, second_segment, 100000)
    print("Target file generated and saved to channel.target")

if __name__ == "__main__":
    main()