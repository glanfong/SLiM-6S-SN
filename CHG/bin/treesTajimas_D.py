# Keywords : python, tree-sequence recording, tree sequence recording, SLiM, ms, tree2ms

# Input : SLiM simulation (.trees file, tree-seq recording)
# Output : sample of diploids in ms format

def treesTajimas_D(id):

    # load .tree file
    tree = pyslim.load(str(id) + "_recap_mut.trees")
    tajD = tree.Tajimas_D()

    if int(id) < 105:
            with open("tajimaD.txt", "a") as file:
                file.write("\n" + str(id) + "\t" + str(tajD) + "\tBTL")

    if int(id) >= 105 and int(id) < 110:
            with open("tajimaD.txt", "a") as file:
                file.write("\n" + str(id) + "\t" + str(tajD) + "\tCST")

    if int(id) >= 110:
            with open("tajimaD.txt", "a") as file:
                file.write("\n" + str(id) + "\t" + str(tajD) + "\tEXP")


    return(tajD)

if __name__ == '__main__' :

    import msprime, tskit, pyslim, sys
    import numpy as np
    import os

    for arg in sys.argv:

        if "=" in arg :
            arg = arg.split("=")
        
        if arg[0]== "id":
            id = str(arg[1])

    if not os.path.isfile("tajimaD.txt"):
        with open("tajimaD.txt", "a") as file:
            file.write("id\ttajD\tscenario")

    treesTajimas_D(id)