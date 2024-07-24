import numpy as np

def generate_points(num_plants=1):
    if not (1 <= num_plants <= 15):
        raise ValueError("Number of plants must be between 1 and 15.")

    # Generate 100 points evenly spaced between (0.05, 0.025) and (0.95, 0.025)
    x1 = np.linspace(0.05, 1.95, 100)
    y1 = np.full_like(x1, 0.025)
    points1 = np.column_stack((x1, y1))

    # Generate 100 points evenly spaced between (0.05, 0.225) and (0.95, 0.225)
    x3 = np.linspace(0.05, 1.95, 100)
    y3 = np.full_like(x3, 0.225)
    points3 = np.column_stack((x3, y3))

    # Generate the plants
    plant_positions = np.linspace(0.5, 1.5, num_plants)
    plant_points = []
    for x in plant_positions:
        x_plant = np.full(3, x)
        y_plant = np.linspace(0.025, 0.125, 3)
        plant_points.append(np.column_stack((x_plant, y_plant)))
    plant_points = np.vstack(plant_points)

    # Combine all points: bottom, top, and plants
    all_points = np.vstack((points1, points3, plant_points))

    return all_points

def save_to_file(filename, points):
    num_points = len(points)
    with open(filename, 'w') as file:
        file.write(f"{num_points}\n")
        for i, point in enumerate(points):
            file.write(f"{point[0]:.16e} {point[1]:.16e}")
            if i < num_points - 1:
                file.write("\n")

def save_targets(filename, num_plants, stiffness):
    with open(filename, 'w') as file:
        # IDs for all points from 1 to 200 and then the base points of the plants
        all_ids = list(range(1, 201))
        base_ids = [200 + i * 3 + 1 for i in range(num_plants)]
        num_points = len(all_ids) + len(base_ids)
        
        file.write(f"{num_points}\n")
        for i, point_id in enumerate(all_ids + base_ids):
            file.write(f"{point_id} {stiffness}")
            if i < num_points - 1:
                file.write("\n")

def save_beams(filename, num_plants, stiffness, constant):
    with open(filename, 'w') as file:
        beam_entries = []
        for i in range(num_plants):
            start_id = 201 + i * 3
            medium_id = 202 + i * 3
            end_id = 203 + i * 3
            beam_entries.append(f"{start_id} {medium_id} {end_id} {stiffness} {constant}")

        file.write(f"{len(beam_entries)}\n")
        for i, entry in enumerate(beam_entries):
            file.write(entry)
            if i < len(beam_entries) - 1:
                file.write("\n")

def main(num_plants=1):
    points = generate_points(num_plants)
    save_to_file("channel.vertex", points)
    print("Points generated and saved to channel.vertex")

    # Save targets with point IDs from 1 to 200 and the base points of the plants, stiffness of 100000
    save_targets("channel.target", num_plants, 100000)
    print("Target file generated and saved to channel.target")

    # Save beams with stiffness of 50000 and constant of 0
    save_beams("channel.beam", num_plants, 10000, 0)
    print("Beam file generated and saved to channel.beam")

if __name__ == "__main__":
    main(num_plants = 5)  # Change this value to generate the desired number of plants