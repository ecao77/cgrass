import matplotlib.pyplot as plt

def read_channel_vertex(file_path):
    with open(file_path, 'r') as file:
        # Read the number of vertices
        num_vertices = int(file.readline().strip())

        # Read the vertices data
        vertices = []
        for line in file:
            x, y = map(float, line.strip().split())
            vertices.append((x, y))

    return num_vertices, vertices

def plot_vertices(vertices):
    x_coords, y_coords = zip(*vertices)

    plt.figure(figsize=(8, 6))
    plt.scatter(x_coords, y_coords, color='blue', marker='o')
    plt.xlabel('X')
    plt.ylabel('Y')
    plt.title('Channel Vertices')
    plt.grid(True)
    plt.show()

# Example usage
file_path = 'channel.vertex'
num_vertices, vertices = read_channel_vertex(file_path)

plot_vertices(vertices)