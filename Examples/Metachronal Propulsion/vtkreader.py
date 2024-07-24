import os

Nx = 240
Ny = 120

def remove_character(string):
    index_e = string.find('e')
    return string[:index_e+1] + string[index_e+1:index_e+2] + string[index_e+3:]

def read_file(file_path):
    file = open(file_path, 'r')
    
    file_sum = 0
    # beginning skips
    for i in range(1, 18):
        line = file.readline()
        
    for i in range(0, Ny):
        line = file.readline()
        valueArray = line[0:len(line)-2].split(' ')
        
        try:
            for entry in valueArray:
                entry = remove_character(entry)
                num = float(entry)
                file_sum += num
        except ValueError:
            print(file_path)
        
    return file_sum/(Nx*Ny)

################################################################################################
################################################################################################
################################################################################################

sum = 0

DIR = 'Downloads/IB2d/Examples/Metachronal Propulsion/squid/viz_IB2d'

number_of_files = len([name for name in os.listdir(DIR) if os.path.isfile(os.path.join(DIR, name)) and 'uX' in name])

for u in range(0, number_of_files):
    sample_string = "0000"
    u_string = str(u)
    while len(u_string) < 4:
        u_string = "0" + u_string
    file_path = DIR + "/uX." + u_string + ".vtk"
    sum += read_file(file_path)/number_of_files
        
print(sum)
