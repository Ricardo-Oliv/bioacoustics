# cd /home/pi/Desktop/deploy_classifier/ && python3 create_barchart.py
# python3 create_barchart.py
# cd /home/pi/Desktop/deploy_classifier/ && chmod 775 create_barchart.py
# /home/pi/Desktop/deploy_classifier/create_barchart.py


import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import time
import re
from PIL import Image

# infile = '/home/pi/Desktop/deploy_classifier/images/graphical_results/test5.csv'
infile = '/home/pi/Desktop/deploy_classifier/From_R_01.csv'

bat_names = np.loadtxt(infile, dtype='str', delimiter=',', skiprows = 0, usecols = None)

# b = np.zeros((10, 15))
# b[:6, :5] = bat_names
# bat_names = b
# ValueError: could not convert string to float: '"BLANK"'

# print("Array bat_names: ",bat_names,"\n")
      
# print(data.shape)
row_count = bat_names.shape[0]  # gives number of row count
col_count = bat_names.shape[1]  # gives number of col count


bat_names[0,1] = bat_names[0,1].strip('""')
# print("bat name no. 1: ",bat_names[0,1],"\n")

#####################################################################
new_bat_names = [None]*11                               # Create a 1D array of 10 new bat names.

for x in range(col_count):
    bat_names[0,x] = bat_names[0,x].strip('""')
    # print("bat name: ",bat_names[0,x])
# print("\n")

for x in range(col_count):
    new_bat_names[x] = bat_names[0,x]
    # print("new names: ",new_bat_names[x])
# print("\n")

# Initially set remainder of bat name labels to "":
for x in range(col_count,11):
    new_bat_names[x] = ""
    # print("new names: ",new_bat_names[x])
# print("\n")

# for x in range(11):
    # print("new names: ",new_bat_names[x])

# Now we can use 'new_bat_names' instead of bat_names!!
#####################################################################

# print("\nThis is the total number of columns:",col_count)
# print("This is the total number of rows:",row_count,"\n")

data = np.loadtxt(infile, dtype='str', delimiter=',', skiprows = 0, usecols = None)
# print("ONE This is data as string before being transposed: \n",data)

# For some reason, the last column is of type string rather than float. Weird !!!!
# Try stripping the quotation marks in last column:
for x in range(1,row_count):
    data[x,col_count-1] = data[x,col_count-1].strip('""')
    # print(data[x,col_count-1])
# print("TWO. This is data as string before being transposed: \n",data)

# data = np.genfromtxt(infile, dtype='str', delimiter=',', names=True) 

# data = np.loadtxt(infile, delimiter=',', skiprows = 1, usecols = range(1,col_count))
# data = np.loadtxt(infile, dtype='str', delimiter=',', skiprows = 1, usecols = range(1,col_count))
# ERROR: ValueError: could not convert string to float: '"12"'
# This error only occurs in the last column !!!!

data = np.delete(data, (0), axis=0)                    # Delete first row.
data = np.delete(data, (0), axis=1)                    # Delete first column.
# print("THREE. This is data as string before being transposed: \n",data)



# For some reason, the last column is of type string rather than float. Weird !!!!
# Try stripping the quotation marks in last column:
# if (col_count > 2):
    # for x in range(0,row_count-1):
        # data[x,col_count-2] = data[x,col_count-2].strip('""')
        # data.strip('""')
        # print(data[x,col_count-2])
# print("FOUR. This is data as string before being transposed: \n",data)

# if (col_count == 2):
    # print("Before: ",data)
    # data = re.sub('["]', '', data)       # Strip char "
    # print(data)

# data = np.loadtxt(infile, delimiter=',', skiprows = 1, usecols = None )
data = data.transpose()

########################################################
b = np.zeros((15, 10))
# columns, rows
b[:col_count-1, :row_count-1] = data
# ERROR: ValueError: could not broadcast input array from shape (5,8) into shape (4,5)
# This is the total number of columns: 6
# This is the total number of rows: 9 
data = b
########################################################

# print("\n This is b below: ")
# print(b)


# print("\n This is array data after being transposed: ")
# print(data)
# print("\n")
# df = pd.DataFrame(np.arange(12).reshape(4,3))

# import the tick labels
xt = np.loadtxt(infile, dtype='str', delimiter=',', skiprows = 1, usecols = (0,))
# print("\n This is xt, the x axis time labels:")
# print(xt)
# print("\n")

if (row_count == 2):
    z = int(xt)
    xt = time.strftime('%H:%M:%S', time.localtime(z))
    # print("Time: ", xt )
else:
    for x in range(row_count-1):
        z = int(xt[x])
        xt[x] = time.strftime('%H:%M:%S', time.localtime(z))
    # print("Time: ", xt[x] )
# print("\n")


# print(data.shape)
# row_count = data.shape[0]  # gives number of row count
col_count = data.shape[1]  # gives number of col count


width = 0.55
# ind = np.arange(11) + 0.75
ind = np.arange(col_count) + 0.75                             # We need to know the number of rows of data!


# print("data[2]:",data[2])
# print("data[3]:",data[3])
# print("data[9]:",data[9])
# print("data[10]:",data[10])
# print("data[11]:",data[11])

fig, ax = plt.subplots(1,1)
p0 = ax.bar(ind, data[0], width, color = 'cyan')
p1 = ax.bar(ind, data[1], width, bottom = data[0], color = 'violet')
p2 = ax.bar(ind, data[2], width, bottom = data[0] + data[1], color = 'green')
p3 = ax.bar(ind, data[3], width, bottom = data[0] + data[1] + data[2], color = 'red')
p4 = ax.bar(ind, data[4], width, bottom = data[0] + data[1] + data[2]  + data[3] , color = 'blue')
p5=ax.bar(ind,data[5],width,bottom=data[0]+data[1]+data[2]+data[3]+data[4] ,color='yellow')
p6=ax.bar(ind,data[6],width,bottom=data[0]+data[1]+data[2]+data[3]+data[4]+data[5]  ,color='grey')
p7=ax.bar(ind,data[7],width,bottom=data[0]+data[1]+data[2]+data[3]+data[4]+data[5]+data[6]  ,color='salmon')
p8=ax.bar(ind,data[8],width,bottom=data[0]+data[1]+data[2]+data[3]+data[4]+data[5]+data[6]+data[7]  ,color='magenta')
p9=ax.bar(ind,data[9],width,bottom=data[0]+data[1]+data[2]+data[3]+data[4]+data[5]+data[6]+data[7]+data[8]  ,color='brown')
p10=ax.bar(ind,data[10],width,bottom=data[0]+data[1]+data[2]+data[3]+data[4]+data[5]+data[6]+data[7]+data[8]+data[9]  ,color='orange')

ax.set_ylabel('frequency (per hour)')
# ax.set_xlabel('hour of the day')
ax.set_xticks (ind + width/2.)
ax.set_xticklabels( xt, rotation = 45 )                       # This is where the x axis labels are set.


# fig.legend( (p0[0], p1[0], p2[0], p3[0]), ('c_pip', 's_pip', 'n_pip', 'noctule') )
# fig.legend( (p0[0], p1[0], p2[0]), (bat_names[0,1], bat_names[0,2], bat_names[0,3]) )

# fig.legend( (p0[0], p1[0], p2[0], p3[0]), (new_bat_names[1],
#                new_bat_names[2], new_bat_names[3], new_bat_names[4]) )

fig.legend( (p0[0], p1[0], p2[0], p3[0] , p4[0], p5[0], p6[0], p7[0], p8[0], p9[0]  ), 
           (new_bat_names[1], new_bat_names[2], new_bat_names[3], new_bat_names[4], new_bat_names[5], new_bat_names[6] , new_bat_names[7] , new_bat_names[8] , new_bat_names[9] , new_bat_names[10] ) )

# plt.rcParams["figure.figsize"] = [6.8,3.2]
# plt.rcParams["figure.figsize"] = [3,2]

# plt.figure(figsize=(3,4))

# plt.rcParams['figure.figsize'] = [6.5, 5.5]
# plt.rcParams['figure.figsize'] = [3, 2]

# plt.subplot(211)
# plt.show()
fig.legend(loc=(1.15, 0.6))
# figsize=(3,2)


# fig.tight_layout()
# fig.show()
# plt.show()

# plt.figure(figsize=(3,2))

# plt.savefig('/home/pi/Desktop/deploy_classifier/images/graphical_results/graph.png', bbox_inches='tight', figsize=(3,2))
fig.savefig('/home/pi/Desktop/deploy_classifier/images/graphical_results/graph.png', bbox_inches='tight', figsize=(3,2))


# Rezize the image:
quality_val = 100
filename = '/home/pi/Desktop/deploy_classifier/images/graphical_results/graph.png'
img = Image.open(filename)
new_img = img.resize((580,230), Image.ANTIALIAS)
# new_img = img.resize((500,500), Image.ANTIALIAS)
new_img.save(filename, "png", quality=quality_val)



# fig = plt.figure(figsize=(4,3))
# ax = fig.add_subplot(111)
# ax.plot(list1, list2)
# fig.savefig('fig1.png', dpi = 300)
# fig.close()
