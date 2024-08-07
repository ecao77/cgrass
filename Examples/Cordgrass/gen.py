import numpy as np

def generate_points(num_plants=1, num_wall_points=100, plant_heights=None):
    if not (1 <= num_plants <= 15):
        raise ValueError("Number of plants must be between 1 and 15.")
    
    if plant_heights is None:
        plant_heights = [1.0] * num_plants  # Default height of 1 meter if not specified
    elif isinstance(plant_heights, (int, float)):
        plant_heights = [plant_heights] * num_plants  # Use the same height for all plants
    elif len(plant_heights) != num_plants:
        raise ValueError("The number of plant heights must match the number of plants.")

    # Generate bottom wall points
    x_bottom = np.linspace(0.05, 1.95, num_wall_points)
    y_bottom = np.full_like(x_bottom, 0.025)
    bottom_wall_points = np.column_stack((x_bottom, y_bottom))

    # Generate top wall points
    x_top = np.linspace(0.05, 1.95, num_wall_points)
    y_top = np.full_like(x_top, 1.975)
    top_wall_points = np.column_stack((x_top, y_top))

    # Generate the plants with variable heights
    plant_x_positions = np.linspace(0.5, 1.5, num_plants)
    plant_points = []
    for x, height in zip(plant_x_positions, plant_heights):
        x_plant = np.full(3, x)
        y_plant = np.linspace(0.025, 0.025 + height, 3)  # Variable height, starting from y=0.025
        plant_points.append(np.column_stack((x_plant, y_plant)))
    plant_points = np.vstack(plant_points)

    # Combine all points: bottom wall, top wall, and plants
    all_points = np.vstack((bottom_wall_points, top_wall_points, plant_points))

    return all_points

def save_to_file(filename, points):
    num_points = len(points)
    with open(filename, 'w') as file:
        file.write(f"{num_points}\n")
        for i, point in enumerate(points):
            file.write(f"{point[0]:.16e} {point[1]:.16e}")
            if i < num_points - 1:
                file.write("\n")

def save_targets(filename, num_plants, num_wall_points, stiffness):
    with open(filename, 'w') as file:
        total_wall_points = 2 * num_wall_points
        wall_ids = list(range(1, total_wall_points + 1))
        plant_base_ids = [total_wall_points + i * 3 + 1 for i in range(num_plants)]
        num_target_points = len(wall_ids) + len(plant_base_ids)
        
        file.write(f"{num_target_points}\n")
        for i, point_id in enumerate(wall_ids + plant_base_ids):
            file.write(f"{point_id} {stiffness}")
            if i < num_target_points - 1:
                file.write("\n")

def save_beams(filename, num_plants, num_wall_points, stiffness, constant):
    with open(filename, 'w') as file:
        beam_entries = []
        total_wall_points = 2 * num_wall_points
        for i in range(num_plants):
            start_id = total_wall_points + 1 + i * 3
            middle_id = total_wall_points + 2 + i * 3
            end_id = total_wall_points + 3 + i * 3
            beam_entries.append(f"{start_id} {middle_id} {end_id} {stiffness} {constant}")

        file.write(f"{len(beam_entries)}\n")
        for i, entry in enumerate(beam_entries):
            file.write(entry)
            if i < len(beam_entries) - 1:
                file.write("\n")

def main(num_plants=1, num_wall_points=100, plant_heights=None):
    points = generate_points(num_plants, num_wall_points, plant_heights)
    save_to_file("channel.vertex", points)
    print("Points generated and saved to channel.vertex")

    save_targets("channel.target", num_plants, num_wall_points, 1e8)
    print("Target file generated and saved to channel.target")

    save_beams("channel.beam", num_plants, num_wall_points, 10000, 0)
    print("Beam file generated and saved to channel.beam")

if __name__ == "__main__":
    # Example usage with a single plant height for all plants
    main(num_plants=15, num_wall_points=100, plant_heights=0.457)