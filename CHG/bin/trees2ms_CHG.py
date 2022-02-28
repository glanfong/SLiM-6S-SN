# Keywords : python, tree-sequence recording, tree sequence recording, SLiM, ms, tree2ms

# Input : SLiM simulation (.trees file, tree-seq recording)
# Output : sample of diploids in ms format

def trees2ms(id):

    # load .tree file
    tree = pyslim.load(str(id) + ".trees")

    # recap the tree
    recap_tree = pyslim.recapitate(tree, recombination_rate = r, ancestral_Ne = Ne_init)
    #recap_tree = tree.recapitate(recombination_rate = r, Ne = Ne_init)
    recap_tree.dump("./" + str(id) + "_recap.trees") # save the recapitated trees

    # check if only 1 root for all trees - else ERROR
    assert(max([t.num_roots for t in recap_tree.trees()]) == 1)

    # add neutral mutations to tree - /!\ keep=True to keep existing mutations /!\
    recap_mut_tree = pyslim.SlimTreeSequence(msprime.mutate(recap_tree, rate=mu, keep=True))
    recap_mut_tree.dump("./" + str(id) + "_recap_mut.trees") # save the recapitated & mutated trees

    # Sample "samp" individuals from the population

    alive = recap_mut_tree.individuals_alive_at(0)
    sample_inds = np.random.choice(alive, samp, replace=False)

    # Simplify tree sequence to contain only "samp" individuals

    keep_nodes = []

    for i in sample_inds:
        keep_nodes.extend(recap_mut_tree.individual(i).nodes)

    simp_recap_mut_tree = recap_mut_tree.simplify(keep_nodes)

    # Write the ms output

    ms_output = open("./" + str(id) + ".ms", "w")

    tskit.write_ms(simp_recap_mut_tree, ms_output)

    ms_output.close()


    return()

if __name__ == '__main__' :

    import msprime, tskit, pyslim, sys
    import numpy as np

    if (len(sys.argv) != 7) :
        sys.exit("Argument missing")

    else :
        for arg in sys.argv:

            if "=" in arg :
                arg = arg.split("=")

            if arg[0] == "Ne_init":
                Ne_init = int(arg[1])

            if arg[0] == "r":
                r = float(arg[1])

            if arg[0]== "mu":
                mu = float(arg[1])

            if arg[0]== "L":
                L = int(arg[1])
            
            if arg[0]== "id":
                id = str(arg[1])

            if arg[0]== "samp":
                samp = int(arg[1])


    trees2ms(id)